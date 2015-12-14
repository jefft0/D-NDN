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

module net.named_data.dndn.util.blob;

import std.array;
import std.conv;
import std.format;
import std.algorithm.comparison;

/**
 * A Blob holds a pointer to an immutable ubyte array.  We use an immutable
 * buffer so that it is OK to pass the object into methods because the new or
 * old owner can’t change the bytes.
 * Note that the pointer to the ubyte array can be null.
 * Blob is defined as a struct, not a class, because it only holds a pointer to an
 * immutable array, so pass by value is correct and more efficient, and the struct
 * avoids allocating a class on the heap.
 */
struct Blob
{
  this(const Blob blob)
  {
    buffer_ = blob.buffer_;
  }

  this(immutable(ubyte)[] buffer)
  { 
    buffer_ = buffer; 
  }
  
  this(const ubyte[] buffer, bool copy = true)
  {
    if (buffer != null) {
      if (copy)
        buffer_ = buffer.idup;
      else
        buffer_ = cast(immutable(ubyte[]))buffer;
    }
  }

  this(const int[] buffer)
  {
    if (buffer != null)
      buffer_ = to!(immutable(ubyte)[])(buffer);
  }

  this(string value)
  {
    // A string is already an array of immutable 8-bit UTF-8 code points, so just cast.
    buffer_ = cast(immutable(ubyte[]))value;
  }

  immutable(ubyte)[]
  buf() const { return buffer_; }

  size_t
  size() const { return buffer_.length; }

  bool
  isNull() const { return buffer_ == null; }

  bool
  equals(const Blob other) const { return buffer_ == other.buffer_; }

  int
  compare(const Blob other) const
  {
    if (buffer_ == null && other.buffer_ == null)
      return 0;
    if (buffer_ == null && other.buffer_ != null)
      return -1;
    if (buffer_ != null && other.buffer_ == null)
      return 1;

    return cmp(buffer_, other.buffer_);
  }

  // Note: The automatic == operator is already correct.

  string
  toString() const
  {
    if (buffer_ == null)
      return "";
    else
      // A string is already an array of immutable 8-bit UTF-8 code points, so just cast.
      return cast(string)buffer_;
  }

  string
  toHex() const { return buffer_ == null ? "" : toHex(buffer_); }
  
  static string
  toHex(const ubyte[] buffer)
  {
    auto output = appender!string();
    foreach (x; buffer)
      formattedWrite(output, "%02x", x);

    return output.data;
  }

  private immutable ubyte[] buffer_;
}
