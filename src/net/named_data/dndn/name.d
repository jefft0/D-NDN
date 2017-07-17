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
    /**
     * Create a new Name.Component with a zero-length value.
     */
    this()
    { 
      value_ = Blob(new immutable(ubyte)[0]); 
    }

    /**
     * Create a new Name.Component, using the existing the Blob value.
     * Params:
     * value = The component value.  value may not be null, but
     *   value.buf() may be null.
     */
    this(const Blob value)
    { 
      value_ = value; 
    }

    /**
     * Create a new Name.Component, taking another pointer to the component's
     * read-only value.
     * Params:
     * component = The component to copy.
     */
    this(const Component component)
    {
      value_ = component.value_;
    }

    /**
     * Create a new Name.Component and take the immutable ubyte array as the component's
     * read-only value.
     * Params:
     * buffer = The immutable ubyte array for the value. This may be null.
     */
    this(immutable(ubyte)[] buffer)
    { 
      value_ = Blob(buffer); 
    }

    /**
     * Create a new Name.Component from the string value.
     * Params:
     * value = The string (which in D is already UTF-8 encoded).
     * Note: This does not escape %XX values.  If you need to escape, use
     * Name.fromEscapedString.
     */
    this(string value)
    { 
      value_ = Blob(value); 
    }

    /**
     * Get the component value.
     * Returns: The component value.
     */
    final Blob
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

    /**
     * Check if this is the same component as other.
     * Params:
     * other = The other Component to compare with.
     * Returns: true if the components are equal, otherwise false.
     */
    final bool
    equals(const Component other) const { return value_.equals(other.value_); }

    override bool 
    opEquals(Object other) const 
    {
      auto component = cast(Component)other;
      if (!component)
        return false;
      
      return equals(component);
    }

    /**
     * Compare this to the other Component using NDN canonical ordering.
     * Params:
     * other = The other Component to compare with.
     * Returns 0 If they compare equal, -1 if this comes before other in the
     * canonical ordering, or 1 if this comes after other in the canonical
     * ordering.
     */
    final int
    compare(const Component other) const
    {
      if (value_.size() < other.value_.size())
        return -1;
      if (value_.size() > other.value_.size())
        return 1;
      
      // The components are equal length. Just do a byte compare.
      return value_.compare(other.value_);
    }

    override int 
    opCmp(Object other) const { return compare(cast(Component)other); }

    private Blob value_;
  }

  /**
   * Create a new Name with no components.
   */
  this()
  {
    components_ = new Component[0];
  }

  /**
   * Create a new Name with the components in the given name.
   * Params:
   * name = The name with components to copy from.
   */
  this(const Name name)
  {
    components_ ~= name.components_;
  }

  /**
   * Create a new Name, copying the components.
   * Params:
   * components = The components to copy.
   */
  this(const Component[] components)
  {
    foreach (component; components)
      enforce(component !is null, "A name component cannot be a null object");
    components_ ~= components;
  }

  // TODO: this(string uri)

  /**
   * Get the number of components.
   * Returns: The number of components.
   */
  final size_t
  size() const { return components_.length; }

  /**
   * Get the component at the given index.
   * Params:
   * i = The index of the component, starting from 0. However, if i is
   *   negative, return the component at size() - (-i).
   * Returns: The name component at the index.
   */
  final const(Component)
  get(int i) const
  {
    if (i >= 0)
      return components_[i];
    else
      return components_[components_.length - (-i)];
  }

  // TODO: set

  /**
   * Clear all the components.
   */
  final void
  clear()
  {
    components_.length = 0;
    ++changeCount_;
  }

  /**
   * Append a new component, taking the immutable ubyte array as the component value.
   * Params:
   * value = The immutable ubyte array for the component.
   * Returns: This name so that you can chain calls to append.
   */
  final Name
  append(immutable(ubyte)[] value)
  {
    return append(new Component(value));
  }

  /**
   * Append a new component, using the existing Blob value.
   * Params:
   * value = The component value.
   * Returns: This name so that you can chain calls to append.
   */
  final Name
  append(const Blob value)
  {
    return append(new const Component(value));
  }

  /**
   * Append the component to this name.
   * Params:
   * component = The component to append.
   * Returns: This name so that you can chain calls to append.
   */
  final Name
  append(const Component component)
  {
    components_ ~= component;
    ++changeCount_;
    return this;
  }

  /**
   * Append all the components of the given name to this name.
   * Params:
   * name = The Name with components to append.
   * Returns: This name so that you can chain calls to append.
   */
  final Name
  append(const Name name)
  {
    if (name is this)
      // Copying from this name, so need to make a copy first.
      return append(new Name(name));

    components_ ~= name.components_;
    return this;
  }

  /**
   * Append a component from the string value.
   * Params:
   * value = The string (which in D is already UTF-8 encoded).
   * Note: This does not escape %XX values.  If you need to escape, use
   * Name.fromEscapedString. Also, if the string has "/", this does not split
   * into separate components.  If you need that then use
   * append(new Name(value)).
   */
  final Name
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

  /**
   * Check if this name has the same component count and components as the given
   * name.
   * Params:
   * name = The Name to check.
   * Returns: true if the object is a Name and the names are equal, otherwise
   * false.
   */
  final bool
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

  override bool 
  opEquals(Object other) const 
  {
    auto name = cast(Name)other;
    if (!name)
      return false;
    
    return equals(name);
  }

  // TODO: final match
  // TODO: final wireEncode
  // TODO: final wireDecode

  /**
   * Compare this to the other Name using NDN canonical ordering.  If the first
   * components of each name are not equal, this returns -1 if the first comes
   * before the second using the NDN canonical ordering for name components, or
   * 1 if it comes after. If they are equal, this compares the second components
   * of each name, etc.  If both names are the same up to the size of the
   * shorter name, this returns -1 if the first name is shorter than the second
   * or 1 if it is longer.  For example, sorted gives:
   * /a/b/d /a/b/cc /c /c/a /bb .  This is intuitive because all names with the
   * prefix /a are next to each other.  But it may be also be counter-intuitive
   * because /c comes before /bb according to NDN canonical ordering since it is
   * shorter.
   * Params:
   * other = The other Name to compare with.
   * Returns: 0 If they compare equal, -1 if this Name comes before other in the
   * canonical ordering, or 1 if this Name comes after other in the canonical
   * ordering.
   * See_Also: 
   * <a href="http://named-data.net/doc/0.2/technical/CanonicalOrder.html">Canonical Order</a>
   */
  final int
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

  override int 
  opCmp(Object other) const { return compare(cast(Name)other); }

  final ulong
  getChangeCount() const { return changeCount_; }

  // TODO: fromEscapedString
  // TODO: toEscapedString

  private const(Component)[] components_;
  private ulong changeCount_ = 0;
}
