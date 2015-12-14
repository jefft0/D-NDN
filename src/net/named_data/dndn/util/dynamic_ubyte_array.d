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

module net.named_data.dndn.util.dynamic_ubyte_array;

/**
 * A DynamicUbyteArray maintains a ubyte array and provides methods to ensure a
 * minimum capacity, resizing if necessary. You can access the array with array().
 */
class DynamicUbyteArray {
  /**
   * Create a DynamicUbyteArray array with a ubyte array of size length.
   * Params:
   * length = (optional) The initial length of the array. If omitted, 
   * use a default.
   */
  this(size_t length = 16)
  {
    array_ = new ubyte[length];
  }

  /**
   * Ensure that array() has the length, reallocate and copy if necessary.
   * This updates the length of array() which may be greater than length.
   * Params:
   * length = The minimum length for the array.
   */
  void 
  ensureLength(size_t length)
  {
    if (array_.length >= length)
      return;
    
    // See if double is enough.
    auto newLength = array_.length * 2;
    if (length > newLength)
      // The needed length is much greater, so use it.
      newLength = length;
    
    array_.length = newLength;
  }

  /**
   * Copy value to array() at offset, reallocating if necessary.
   * Params:
   * value = The ubyte array to copy.
   * offset = The offset in array() to start copying into.
   * Returns: The offset in array() at the end of the copied value, 
   * which is offset + value.length.
   */
  size_t
  copy(const ref ubyte[] value, size_t offset)
  {
    auto endOffset = value.length + offset;
    ensureLength(endOffset);

    array_[offset..endOffset] = value;

    return endOffset;
  }

  /**
   * Ensure that array() has the length. If necessary, reallocate the array
   * and shift existing data to the back of the new array.
   * This updates the length of array() which may be greater than length.
   * Params:
   * length = The minimum length for the array.
   */
  void
  ensureLengthFromBack(size_t length)
  {
    if (array_.length >= length)
      return;
    
    // See if double is enough.
    auto newLength = array_.length * 2;
    if (length > newLength)
      // The needed length is much greater, so use it.
      newLength = length;

    auto newArray = new ubyte[newLength];
    // Copy to the back of newArray.
    newArray[$ - array_.length..$] = array_;
    array_ = newArray;
  }

  /**
   * First call ensureLengthFromBack to make sure that array() has
   * offsetFromBack bytes, then copy value into the array starting
   * offsetFromBack bytes from the back of the array.
   * Params:
   * value = The ubyte array to copy.
   * offsetFromBack = The offset from the back of array() to start
   * copying.
   */
  void
  copyFromBack(const ref ubyte[] value, size_t offsetFromBack)
  {
    ensureLengthFromBack(offsetFromBack);
    auto startOffset = array_.length - offsetFromBack;
    array_[startOffset..startOffset + value.length] = value;
  }

  /**
   * Get the ubyte array.
   * Returns: A reference to the ubyte array. Note that ensureLength
   * can change the length.
   */
  ref ubyte[]
  array() { return array_; }

  private ubyte[] array_;
}
