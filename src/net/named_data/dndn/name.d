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

module net.named_data.dndn.name;

import std.exception;
import net.named_data.dndn.util.blob;
import net.named_data.dndn.util.change_countable;

/**
 * A Name holds an array of Name.Component and represents an NDN name.
 */
class Name : ChangeCountable {
  /**
   * A Name.Component holds a read-only name component value.
   */
  static class Component {
    this()
    { 
      value_ = Blob(new immutable(ubyte)[0]); 
    }

    this(const Blob value)
    { 
      value_ = value; 
    }

    this(const Component component)
    {
      value_ = component.value_;
    }

    this(immutable(ubyte)[] buffer)
    { 
      value_ = Blob(buffer); 
    }

    this(string value)
    { 
      value_ = Blob(value); 
    }

    Blob
    getValue() const { return value_; }

    // TODO: toEscapedString
    // TODO: toNumber
    // TODO: toNumberWithMarker
    // TODO: toSegment
    // TODO: toSegmentOffset
    // TODO: toVersion
    // TODO: toTimestamp
    // TODO: toSequenceNumber
    // TODO: fromNumber
    // TODO: fromNumberWithMarker

    bool
    equals(const Component other) const { return value_.equals(other.value_); }

    int
    compare(const Component other) const
    {
      if (value_.size() < other.value_.size())
        return -1;
      if (value_.size() > other.value_.size())
        return 1;
      
      // The components are equal length. Just do a byte compare.
      return value_.compare(other.value_);
    }

    private Blob value_;
  }

  this()
  {
    components_ = new Component[0];
  }

  this(const Name name)
  {
    components_ = (cast(Component[])name.components_).dup;
  }

  this(const Component[] components)
  {
    foreach (component; components)
      enforce(component !is null, "A name component cannot be a null object");
    components_ = (cast(Component[])components).dup;
  }

  // TODO: this(string uri)

  size_t
  size() const { return components_.length; }

  const(Component)
  get(int i) const
  {
    if (i >= 0)
      return components_[i];
    else
      return components_[components_.length - (-i)];
  }

  // TODO: set

  void
  clear()
  {
    components_ = new Component[0];
    ++changeCount_;
  }

  Name
  append(immutable(ubyte)[] value)
  {
    return append(new Component(value));
  }

  Name
  append(const Blob value)
  {
    return append(new Component(value));
  }

  Name
  append(const Component component)
  {
    components_ ~= component;
    ++changeCount_;
    return this;
  }

  Name
  append(const Name name)
  {
    if (name is this)
      // Copying from this name, so need to make a copy first.
      return append(new Name(name));

    components_ ~= name.components_;
    return this;
  }

  Name
  append(string value)
  {
    return append(new Component(value));
  }

  // TODO: getSubName
  // TODO: getPrefix
  // TODO: toUri
  // TODO: appendSegment
  // TODO: appendSegmentOffset
  // TODO: appendVersion
  // TODO: appendTimestamp
  // TODO: appendSequenceNumber

  bool
  equals(const Name name) const
  {
    if (components_.length != name.components_.length)
      return false;
    
    // Check from last to first since the last components are more likely to differ.
    for (int i = cast(int)components_.length - 1; i >= 0; --i) {
      if (!get(i).getValue().equals(name.get(i).getValue()))
        return false;
    }
    
    return true;
  }

  // TODO: match
  // TODO: wireEncode
  // TODO: wireDecode

  int
  compare(const Name other) const
  {
    for (int i = 0; i < size() && i < other.size(); ++i) {
      int comparison = components_[i].compare(other.components_[i]);
      if (comparison == 0)
        // The components at this index are equal, so check the next components.
        continue;
      
      // Otherwise, the result is based on the components at this index.
      return comparison;
    }
    
    // The components up to min(this.size(), other.size()) are equal, so the
    //   shorter name is less.
    if (size() < other.size())
      return -1;
    else if (size() > other.size())
      return 1;
    else
      return 0;
  }

  ulong
  getChangeCount() const { return changeCount_; }

  // TODO: fromEscapedString
  // TODO: toEscapedString

  private const(Component)[] components_;
  private ulong changeCount_ = 0;
}

