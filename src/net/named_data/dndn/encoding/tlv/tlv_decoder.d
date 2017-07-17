/*
 * Copyright (C) 2015-2017 Regents of the University of California.
 * @author: Jeff Thompson <jefft0@remap.ucla.edu>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * A copy of the GNU Lesser General Public License is in the file COPYING.
 */

module net.named_data.dndn.encoding.tlv.tlv_decoder;

import core.exception;
import std.bitmanip;
import net.named_data.dndn.encoding.encoding_exception;

/**
 * A TlvDecoder has methods to decode an input according to NDN-TLV.
 */
class TlvDecoder {
  /*
   * Create a new TlvDecoder to decode the input and initialize the
   * reading offset to 0.
   * Params:
   * input = The ubyte array with the bytes to decode. This takes an
   * immutable array so that slices of the input can be supplied as
   * immutable results.
   */
  this(immutable(ubyte)[] input)
  {
    input_ = input;
  }

  /**
   * Decode a VAR-NUMBER in NDN-TLV and return it. Update offset. We limit 
   * to 32 bits because this is used for the TLV type and length which we 
   * don't expect to be 64 bits.
   * Returns: The decoded VAR-NUMBER as a size_t which we expect to be
   * at least 32 bits (and used mostly to represent array length).
   * Throws: EncodingException if the VAR-NUMBER is 64-bit or read past the end
   * of the input.
   */
  final size_t
  readVarNumber()
  {
    try {
      int firstOctet = input_[offset_];
      offset_ += 1;
      if (firstOctet < 253)
        return firstOctet;
      else
        return readExtendedVarNumber(firstOctet);
    } catch (RangeError ex) {
      throw new EncodingException("Read past the end of the input");
    }
  }

  /**
   * Do the work of readVarNumber, given the firstOctet which is >= 253.
   * Update offset.
   * Params:
   * firstOctet = The first octet which is >= 253, used to decode
   * the remaining bytes.
   * Returns: The decoded VAR-NUMBER as a size_t which we expect to be
   * at least 32 bits (and used mostly to represent array length).
   */
  final size_t
  readExtendedVarNumber(int firstOctet)
  {
    try {
      if (firstOctet == 253) {
        ubyte[2] bigEndian = input_[offset_..offset_ + 2];
        offset_ += 2;
        return bigEndianToNative!ushort(bigEndian);
      }
      else if (firstOctet == 254) {
        ubyte[4] bigEndian = input_[offset_..offset_ + 4];
        offset_ += 4;
        return bigEndianToNative!uint(bigEndian);
      }
      else
        // we are returning a 32-bit int, so can't handle 64-bit.
        throw new EncodingException
          ("Decoding a 64-bit VAR-NUMBER is not supported");
    } catch (RangeError ex) {
      throw new EncodingException("Read past the end of the input");
    }
  }

  /**
   * Decode the type and length from the input starting at offset, expecting
   * the type to be expectedType and return the length. Update offset.  Also make
   * sure the decoded length does not exceed the number of bytes remaining in the
   * input.
   * Params:
   * expectedType = The expected type.
   * Returns: The length of the TLV.
   * Throws: EncodingException if did not get the expected TLV type or the TLV length
   * exceeds the buffer length.
   */
  final size_t
  readTypeAndLength(int expectedType)
  {
    auto type = this.readVarNumber();
    if (type != expectedType)
      throw new EncodingException("Did not get the expected TLV type");
      
    auto length = this.readVarNumber();
    if (offset_ + length > input_.length)
      throw new EncodingException("TLV length exceeds the buffer length");
      
    return length;
  }

  /**
   * Decode the type and length from the input starting at offset, expecting the
   * type to be expectedType.  Update offset.  Also make sure the decoded length
   * does not exceed the number of bytes remaining in the input. Return the offset
   * of the end of this parent TLV, which is used in decoding optional nested
   * TLVs. After reading all nested TLVs, call finishNestedTlvs.
   * Params:
   * expectedType = The expected type.
   * Returns: The offset of the end of the parent TLV.
   * Throws: EncodingException if did not get the expected TLV type or the TLV
   * length exceeds the buffer length.
   */
  final size_t
  readNestedTlvsStart(int expectedType)
  {
    return readTypeAndLength(expectedType) + offset_;
  }

  /**
   * Call this after reading all nested TLVs to skip any remaining unrecognized
   * TLVs and to check if the offset after the final nested TLV matches the
   * endOffset returned by readNestedTlvsStart.
   * Params:
   * endOffset = The offset of the end of the parent TLV, returned
   * by readNestedTlvsStart.
   * Throws: EncodingException if the TLV length does not equal the total length
   * of the nested TLVs.
   */
  final void
  finishNestedTlvs(size_t endOffset)
  {
    // We expect offset to be endOffset, so check this first.
    if (offset_ == endOffset)
      return;
    
    // Skip remaining TLVs.
    while (offset_ < endOffset) {
      // Skip the type VAR-NUMBER.
      readVarNumber();
      // Read the length and update offset.
      auto length = readVarNumber();
      offset_ += length;
      
      if (offset_ > input_.length)
        throw new EncodingException("TLV length exceeds the buffer length");
    }
    
    if (offset_ != endOffset)
      throw new EncodingException
        ("TLV length does not equal the total length of the nested TLVs");
  }

  /**
   * Decode the type from this decoder's input starting at offset, and if it is the
   * expectedType, then return true, else false.  However, if this decoer's offset is
   * greater than or equal to endOffset, then return false and don't try to read
   * the type. Do not update offset.
   * Params:
   * expectedType = The expected type.
   * endOffset = The offset of the end of the parent TLV, returned
   * by readNestedTlvsStart.
   * Returns: true if the type of the next TLV is the expectedType,
   * otherwise false.
   */
  final bool
  peekType(int expectedType, size_t endOffset)
  {
    if (offset_ >= endOffset)
      // No more sub TLVs to look at.
      return false;
    else {
      auto saveOffset = offset_;
      auto type = readVarNumber();
      // Restore offset.
      offset_ = saveOffset;
      
      return type == expectedType;
    }
  }

  // TODO: final readNonNegativeInteger
  // TODO: final readNonNegativeIntegerTlv
  // TODO: final readOptionalNonNegativeIntegerTlv

  /**
   * Decode the type and length from this's input starting at offset, expecting
   * the type to be expectedType. Then return an array of the bytes in the value.
   * Update offset.
   * Params:
   * expectedType = The expected type.
   * Returns: The bytes in the value as a slice on the immutable buffer.
   * Throws: EncodingException if did not get the expected TLV type.
   */
  final immutable(ubyte)[]
  readBlobTlv(int expectedType)
  {
    auto length = readTypeAndLength(expectedType);
    auto result = input_[offset_..offset_ + length];
    
    // readTypeAndLength already checked if length exceeds the input buffer.
    offset_ += length;
    return result;
  }

  /**
   * Peek at the next TLV, and if it has the expectedType then call readBlobTlv
   * and return the value.  Otherwise, return null. However, if this's offset is
   * greater than or equal to endOffset, then return null and don't try to read
   * the type.
   * @param {number} expectedType The expected type.
   * @param {number} endOffset The offset of the end of the parent TLV, returned
   * by readNestedTlvsStart.
   * @returns {Buffer} The bytes in the value as a slice on the buffer or null if
   * the next TLV doesn't have the expected type.  This is not a copy of the bytes
   * in the input buffer.  If you need a copy, then you must make a copy of the
   * return value.
   */
  final immutable(ubyte)[]
  readOptionalBlobTlv(int expectedType, size_t endOffset)
  {
    if (peekType(expectedType, endOffset))
      return readBlobTlv(expectedType);
    else
      return null;
  }

  /**
   * Peek at the next TLV, and if it has the expectedType then read a type and
   * value, ignoring the value, and return true. Otherwise, return false.
   * However, if this decoder's offset is greater than or equal to endOffset, then return
   * false and don't try to read the type.
   * Params:
   * expectedType = The expected type.
   * endOffset = The offset of the end of the parent TLV, returned
   * by readNestedTlvsStart.
   * Returns: true, or else false if the next TLV doesn't have the
   * expected type.
   */
  final bool
  readBooleanTlv(int expectedType, size_t endOffset)
  {
    if (peekType(expectedType, endOffset)) {
      auto length = readTypeAndLength(expectedType);
      // We expect the length to be 0, but update offset anyway.
      offset_ += length;
      return true;
    }
    else
      return false;
  }

  /**
   * Get the offset into the input, used for the next read.
   * Returns: The offset.
   */
  final size_t 
  getOffset() { return offset_; }
  
  /**
   * Set the offset into the input, used for the next read.
   * Params:
   * offset = The new offset.
   */
  final void
  seek(size_t offset) { offset = offset; }

  private immutable(ubyte)[] input_;
  private size_t offset_ = 0;
}
