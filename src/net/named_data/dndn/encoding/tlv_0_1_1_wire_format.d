/*
 * Copyright (C) 2015 Regents of the University of California.
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

module net.named_data.dndn.encoding.tlv_0_1_1_wire_format;

import net.named_data.dndn.util.blob;
import net.named_data.dndn.encoding.wire_format;
import net.named_data.dndn.encoding.tlv.tlv;
import net.named_data.dndn.encoding.tlv.tlv_decoder;
import net.named_data.dndn.name;

/**
 * A Tlv0_1_1WireFormat implements the WireFormat interface for encoding and
 * decoding with the NDN-TLV wire format, version 0.1.1.
 */
class Tlv0_1_1WireFormat : WireFormat
{
  /**
   * Decode input as a name in NDN-TLV and set the fields of the Name object.
   * Params:
   * name = The Name object whose fields are updated.
   * input = The ubyte array with the bytes to decode. This takes an
   * immutable array so that slices of the input can be supplied as
   * immutable results.
   * Throws: EncodingException for invalid encoding.
   */
  void
  decodeName(Name name, ref immutable(ubyte)[] input) const
  {
    TlvDecoder decoder = new TlvDecoder(input);
    size_t dummyBegin, dummyEnd;
    decodeName(name, dummyBegin, dummyEnd, decoder);
  }

  /**
   * Get a singleton instance of a Tlv0_1_1WireFormat.  To always use the
   * preferred version NDN-TLV, you should use TlvWireFormat.get().
   * Return: The singleton instance.
   */
  static Tlv0_1_1WireFormat
  get() { return instance_; }

  /**
   * Decode the name as NDN-TLV and set the fields in name.
   * Params:
   * name = The name object whose fields are set.
   * signedPortionBeginOffset = Return the offset in the encoding of the
   * beginning of the signed portion. The signed portion starts from the first
   * name component and ends just before the final name component (which is
   * assumed to be a signature for a signed interest).
   * If you are not decoding in order to verify, you can ignore this returned value.
   * signedPortionEndOffset = Return the offset in the encoding of the end
   * of the signed portion. The signed portion starts from the first
   * name component and ends just before the final name component (which is
   * assumed to be a signature for a signed interest).
   * If you are not decoding in order to verify, you can ignore this returned value.
   * decoder = The decoder with the input to decode.
   */
  private static void
  decodeName
    (Name name, ref size_t signedPortionBeginOffset,
     ref size_t signedPortionEndOffset, TlvDecoder decoder)
  {
    if (name.size() > 0) // debug
      name.clear();

    auto endOffset = decoder.readNestedTlvsStart(Tlv.Name);
    
    signedPortionBeginOffset = decoder.getOffset();
    // In case there are no components, set signedPortionEndOffset arbitrarily.
    signedPortionEndOffset = signedPortionBeginOffset;
    
    while (decoder.getOffset() < endOffset) {
      signedPortionEndOffset = decoder.getOffset();
      name.append(decoder.readBlobTlv(Tlv.NameComponent));
    }
    
    decoder.finishNestedTlvs(endOffset);
  }

  static this()
  {
    instance_ = new Tlv0_1_1WireFormat();
  }

  private static Tlv0_1_1WireFormat instance_;
}
