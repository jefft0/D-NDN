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
struct Blob {
  /**
   * Create a Blob and take another pointer to the given blob's buffer.
   * Params:
   *   blob = The Blob from which we take another pointer to the same buffer.
   */
  this(ref const Blob blob)
  {
    buffer_ = blob.buffer_;
  }

  /**
   * Create a Blob and take the immutable ubyte array as the given blob's buffer.
   * Params:
   * buffer = The immutable ubyte array for this Blob's buffer. This may be null.
   */
  this(immutable(ubyte)[] buffer)
  { 
    buffer_ = buffer; 
  }
  
  /**
   * Create a new Blob with a copy of the bytes in the array.
   * Params:
   * value = The ubyte array to copy.
   * Note: If you want to create a Blob from a non-immutable ubyte array 
   * without copying, you can explicitly cast with 
   * cast(immutable(ubyte)[])buffer. But it is your responsibility
   * to ensure that other parts of the program don't change the array values.
   */
  this(const(ubyte)[] value)
  {
    if (value != null)
      buffer_ = value.idup;
  }

  /**
   * Create a new Blob with a copy of the bytes in the array.
   * Params:
   * value = The array of int to copy where each integer is in
   * the range 0 to 255.
   */
  this(const int[] value)
  {
    if (value != null)
      buffer_ = to!(immutable(ubyte)[])(value);
  }

  /**
   * Create a new Blob from the string value.
   * Params:
   * value = The string (which in D is already UTF-8 encoded).
   */
  this(string value)
  {
    // A string is already an array of immutable 8-bit UTF-8 code points, so just cast.
    buffer_ = cast(immutable(ubyte[]))value;
  }

  /**
   * Get the immutable ubyte array.
   * Returns: The immutable ubyte array, or null if the pointer is null.
   */
  immutable(ubyte)[]
  buf() const { return buffer_; }

  /**
   * Get the size of the buffer.
   * Returns: The length (remaining) of the ByteBuffer, or 0 if the pointer is
   * null.
   */
  size_t
  size() const { return buffer_.length; }

  /**
   * Check if the buffer pointer is null.
   * Returns: true if the buffer pointer is null, otherwise false.
   */
  bool
  isNull() const { return buffer_ == null; }

  /**
   * Return a hex string of buf().
   * Returns A string of hex bytes, or "" if the buffer is null.
   */
  string
  toHex() const { return buffer_ == null ? "" : toHex(buffer_); }
  
  /**
   * Return a hex string of the contents of buffer.
   * Params:
   * buffer = The buffer.
   * Returns: A string of hex bytes.
   */
  static string
  toHex(const ubyte[] buffer)
  {
    auto output = appender!string();
    foreach (x; buffer)
      formattedWrite(output, "%02x", x);
    
    return output.data;
  }

  /**
   * Check if this is byte-wise equal to the other Blob. If this and other
   * are both isNull(), then this returns true.
   * Params:
   * other = The other Blob to compare with.
   * Returns: true if the blobs are equal, otherwise false.
   */
  bool
  equals(const Blob other) const { return buffer_ == other.buffer_; }

  /**
   * Compare this to the other Blob using byte-by-byte comparison from their
   * position to their limit. If this and other are both isNull(), then this
   * returns 0. If this isNull() and the other is not, return -1. If this is not
   * isNull() and the other is, return 1. We compare explicitly because a Blob
   * uses a ByteBuffer which compares based on signed byte, not unsigned byte.
   * Params:
   * other = The other Blob to compare with.
   * Returns: 0 If they compare equal, -1 if self is less than other, or 1 if
   * self is greater than other.  If both are equal up to the shortest, then
   * return -1 if self is shorter than other, or 1 of self is longer than other.
   */
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

  int 
  opCmp(ref const Blob other) const { return compare(other); }

  // Note: The automatic == operator is already correct.

  /**
   * Get a string from the buffer as UTF-8 encoding.
   * Returns: A string (which in D is already UTF-8 encoded),
   * or "" if the buffer is null.
   */
  string
  toString() const
  {
    if (buffer_ == null)
      return "";
    else
      // A string is already an array of immutable 8-bit UTF-8 code points, so just cast.
      return cast(string)buffer_;
  }

  private immutable ubyte[] buffer_;
}
