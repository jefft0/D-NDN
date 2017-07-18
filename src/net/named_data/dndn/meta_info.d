/*
 * Copyright (C) 2017 Regents of the University of California.
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

module net.named_data.dndn.meta_info;

import std.typecons;
import net.named_data.dndn.content_type;
import net.named_data.dndn.name;
import net.named_data.dndn.util.change_countable;

/**
 * The MetaInfo class is used by Data and represents the fields of an NDN 
 * MetaInfo. The MetaInfo type specifies the type of the content in the Data 
 * packet (usually BLOB).
 */
class MetaInfo : ChangeCountable {
  /**
   * Create a new MetaInfo with default values.
   */
  this()
  {
  }

  /**
   * Create a new MetaInfo with a copy of the fields in the given metaInfo.
   * Params:
   * metaInfo = The MetaInfo to copy.
   */
  this(const MetaInfo metaInfo)
  {
    type_ = metaInfo.type_;
    otherTypeCode_ = metaInfo.otherTypeCode_;
    freshnessPeriod_ = metaInfo.freshnessPeriod_;
    // Name.Component is read-only, so we don't need a deep copy.
    finalBlockId_ = metaInfo.finalBlockId_;
  }

  /**
   * Get the content type.
   * Returns: The content type enum value. If this is ContentType.OTHER_CODE,
   * then call getOtherTypeCode() to get the unrecognized content type code.
   */
  final ContentType
  getType() const { return type_; }
  
  /**
   * Get the content type code from the packet which is other than a recognized
   * ContentType enum value. This is only meaningful if getType() is
   * ContentType.OTHER_CODE.
   * Returns: The type code.
   */
  final int
  getOtherTypeCode() const { return otherTypeCode_; }

  /**
   * Get the freshness period.
   * Returns: The freshness period in milliseconds, or -1 if not specified.
   */
  final double
  getFreshnessPeriod() const { return freshnessPeriod_; }

  /**
   * Get the final block ID.
   * Returns: The final block ID as a Name.Component.  If the Name.Component
   * getValue().size() is 0, then the final block ID is not specified.
   */
  final const(Name.Component)
  getFinalBlockId() const { return finalBlockId_; }

  /**
   * Set the content type.
   * Params: 
   * type = The content type enum value. If the packet's content type is not a 
   * recognized ContentType enum value, use ContentType.OTHER_CODE and
   * call setOtherTypeCode().
   */
  final void
  setType(ContentType type)
  {
    type_ = type;
    ++changeCount_;
  }
  
  /**
   * Set the packet's content type code to use when the content type enum is
   * ContentType.OTHER_CODE. If the packet's content type code is a recognized
   * enum value, just call setType().
   * Params: 
   * otherTypeCode = The packet's unrecognized content type code, which must be 
   * non-negative.
   */
  final void
  setOtherTypeCode(int otherTypeCode)
  {
    if (otherTypeCode < 0)
      throw new Error("MetaInfo other type code must be non-negative");
    
    otherTypeCode_ = otherTypeCode;
    ++changeCount_;
  }

  /**
   * Set the freshness period.
   * Params:
   * freshnessPeriod = The freshness period in milliseconds, or -1 for not 
   * specified.
   */
  final void
  setFreshnessPeriod(double freshnessPeriod)
  {
    freshnessPeriod_ = freshnessPeriod;
    ++changeCount_;
  }

  /**
   * Set the final block ID.
   * Params:
   * finalBlockId = The final block ID.  If finalBlockId is null, set to a
   * Name.Component of size 0 so that the finalBlockId is not specified and not 
   * encoded.
   */
  final void
  setFinalBlockId(const Name.Component finalBlockId)
  {
    finalBlockId_ = (finalBlockId is null ? new Name.Component() : finalBlockId);
    ++changeCount_;
  }

  /**
   * Get the change count, which is incremented each time this object is changed.
   * Returns: The change count.
   */
  final ulong
  getChangeCount() const { return changeCount_; }

  private ContentType type_ = ContentType.BLOB;
  private int otherTypeCode_ = -1;
  private double freshnessPeriod_ = -1; // -1 for none.
  private Rebindable!(const Name.Component) finalBlockId_ = 
    new const Name.Component();
  private ulong changeCount_ = 0;
}
