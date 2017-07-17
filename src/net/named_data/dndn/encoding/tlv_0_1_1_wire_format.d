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
   * Get a singleton instance of a Tlv0_1_1WireFormat.  To always use the
   * preferred version NDN-TLV, you should use TlvWireFormat.get().
   * Return: The singleton instance.
   */
  static Tlv0_1_1WireFormat
  get() { return instance_; }

  static this()
  {
    instance_ = new Tlv0_1_1WireFormat();
  }

  private static Tlv0_1_1WireFormat instance_;
}
