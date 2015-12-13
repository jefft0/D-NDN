/**
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

module net.named_data.dndn.util.signed_blob;

import net.named_data.dndn.util.blob;

/**
 * A SignedBlob has the fields and methods of Blob plus fields to keep 
 * the offsets of a signed portion (e.g., the bytes of Data packet).
 * The methods of Blob are available, including Blob.size and Blob.buf.
 */
class SignedBlob
{
  this(const SignedBlob signedBlob)
  {
    blob_ = Blob(signedBlob.buf(), false);
    signedPortionBeginOffset_ = signedBlob.signedPortionBeginOffset_;
    signedPortionEndOffset_ = signedBlob.signedPortionEndOffset_;
    signedBuffer_ = getSignedBuffer();
  }

  this(const Blob blob, size_t signedPortionBeginOffset, size_t signedPortionEndOffset)
  {
    blob_ = Blob(blob);
    signedPortionBeginOffset_ = signedPortionBeginOffset;
    signedPortionEndOffset_ = signedPortionEndOffset;
    signedBuffer_ = getSignedBuffer();
  }

  this(const ubyte[] buffer, bool copy, 
       size_t signedPortionBeginOffset, size_t signedPortionEndOffset)
  {
    blob_ = Blob(buffer, copy);
    signedPortionBeginOffset_ = signedPortionBeginOffset;
    signedPortionEndOffset_ = signedPortionEndOffset;
    signedBuffer_ = getSignedBuffer();
  }

  this(const ubyte[] value, size_t signedPortionBeginOffset, size_t signedPortionEndOffset)
  {
    blob_ = Blob(value);
    signedPortionBeginOffset_ = signedPortionBeginOffset;
    signedPortionEndOffset_ = signedPortionEndOffset;
    signedBuffer_ = getSignedBuffer();
  }

  size_t
  signedSize() const
  {
    if (signedBuffer_ != null)
      return signedBuffer_.length; 
    else
      return 0;
  }

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

