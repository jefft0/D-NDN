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

module net.named_data.dndn.util.signed_blob;

import net.named_data.dndn.util.blob;

/**
 * A SignedBlob has the fields and methods of Blob plus fields to keep 
 * the offsets of a signed portion (e.g., the bytes of Data packet).
 * The methods of Blob are available, including Blob.size and Blob.buf.
 */
class SignedBlob {
  /**
   * Create a new SignedBlob as a copy of the given signedBlob.
   * Params:
   * signedBlob = The SignedBlob to copy.
   */
  this(const SignedBlob signedBlob)
  {
    blob_ = Blob(signedBlob.buf());
    signedPortionBeginOffset_ = signedBlob.signedPortionBeginOffset_;
    signedPortionEndOffset_ = signedBlob.signedPortionEndOffset_;
    signedBuffer_ = getSignedBuffer();
  }

  /**
   * Create a new SignedBlob and take another pointer to the given blob's
   * buffer.
   * Params: 
   * blob = The Blob from which we take another pointer to the same buffer.
   * signedPortionBeginOffset = The offset in the buffer of the beginning
   * of the signed portion.
   * signedPortionEndOffset = The offset in the buffer of the end of the
   * signed portion.
   */
  this(const Blob blob, size_t signedPortionBeginOffset, size_t signedPortionEndOffset)
  {
    blob_ = Blob(blob);
    signedPortionBeginOffset_ = signedPortionBeginOffset;
    signedPortionEndOffset_ = signedPortionEndOffset;
    signedBuffer_ = getSignedBuffer();
  }

  /**
   * Create a SignedBlob and take the immutable ubyte array as the given blob's buffer.
   * Params:
   * buffer = The immutable ubyte array for this Blob's buffer.
   * signedPortionBeginOffset = The offset in the buffer of the beginning
   * of the signed portion.
   * signedPortionEndOffset = The offset in the buffer of the end of the
   * signed portion.
   */
  this(immutable(ubyte)[] buffer, 
       size_t signedPortionBeginOffset, size_t signedPortionEndOffset)
  {
    blob_ = Blob(buffer);
    signedPortionBeginOffset_ = signedPortionBeginOffset;
    signedPortionEndOffset_ = signedPortionEndOffset;
    signedBuffer_ = getSignedBuffer();
  }

  /**
   * Create a new SignedBlob with a copy of the bytes in the array.
   * Params:
   * value = The ubyte array to copy.
   * signedPortionBeginOffset = The offset in the buffer of the beginning
   * of the signed portion.
   * signedPortionEndOffset = The offset in the buffer of the end of the
   * signed portion.
   * Note: If you want to create a SignedBlob from a non-immutable ubyte array 
   * without copying, you can explicitly cast with 
   * cast(immutable(ubyte)[])buffer. But it is your responsibility
   * to ensure that other parts of the program don't change the array values.
   */
  this(const(ubyte)[] value, size_t signedPortionBeginOffset, size_t signedPortionEndOffset)
  {
    blob_ = Blob(value);
    signedPortionBeginOffset_ = signedPortionBeginOffset;
    signedPortionEndOffset_ = signedPortionEndOffset;
    signedBuffer_ = getSignedBuffer();
  }

  /**
   * Get the length of the signed portion of the immutable ubyte buffer.
   * Returns: The length of the signed portion, or 0 if the pointer is null.
   */
  size_t
  signedSize() const { return signedBuffer_.length; }

  /**
   * Get the slice of the immutable ubyte array for the signed portion 
   * of the ubyte buffer.
   * Returns The the slice of the immutable ubyte array, 
   * or null if the pointer is null.
   */
  immutable(ubyte)[]
  signedBuf() const { return signedBuffer_; }

  private immutable(ubyte)[]
  getSignedBuffer()
  {
    if (!isNull())
      return blob_.buf()[signedPortionBeginOffset_..signedPortionEndOffset_];
    else
      return null;
  }

  immutable Blob blob_;
  // Make all the Blob methods available in this SignedBlob.
  alias blob_ this;

  private immutable ubyte[] signedBuffer_;
  private size_t signedPortionBeginOffset_;
  private size_t signedPortionEndOffset_;
}
