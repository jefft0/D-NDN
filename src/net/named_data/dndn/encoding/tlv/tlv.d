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

module net.named_data.dndn.encoding.tlv.tlv;

/**
 * The Tlv class defines type codes for the NDN-TLV wire format.
 */
class Tlv
{
  static immutable Interest =         5;
  static immutable Data =             6;
  static immutable Name =             7;
  static immutable NameComponent =    8;
  static immutable Selectors =        9;
  static immutable Nonce =            10;
  // static immutable <Unassigned> =  11;
  static immutable InterestLifetime = 12;
  static immutable MinSuffixComponents = 13;
  static immutable MaxSuffixComponents = 14;
  static immutable PublisherPublicKeyLocator = 15;
  static immutable Exclude =          16;
  static immutable ChildSelector =    17;
  static immutable MustBeFresh =      18;
  static immutable Any =              19;
  static immutable MetaInfo =         20;
  static immutable Content =          21;
  static immutable SignatureInfo =    22;
  static immutable SignatureValue =   23;
  static immutable ContentType =      24;
  static immutable FreshnessPeriod =  25;
  static immutable FinalBlockId =     26;
  static immutable SignatureType =    27;
  static immutable KeyLocator =       28;
  static immutable KeyLocatorDigest = 29;
  static immutable SelectedDelegation = 32;
  static immutable FaceInstance =     128;
  static immutable ForwardingEntry =  129;
  static immutable StatusResponse =   130;
  static immutable Action =           131;
  static immutable FaceID =           132;
  static immutable IPProto =          133;
  static immutable Host =             134;
  static immutable Port =             135;
  static immutable MulticastInterface = 136;
  static immutable MulticastTTL =     137;
  static immutable ForwardingFlags =  138;
  static immutable StatusCode =       139;
  static immutable StatusText =       140;
  
  static immutable SignatureType_DigestSha256 = 0;
  static immutable SignatureType_SignatureSha256WithRsa = 1;
  static immutable SignatureType_SignatureSha256WithEcdsa = 3;
  
  static immutable ContentType_Default = 0;
  static immutable ContentType_Link = 1;
  static immutable ContentType_Key = 2;
  
  static immutable NfdCommand_ControlResponse = 101;
  static immutable NfdCommand_StatusCode =      102;
  static immutable NfdCommand_StatusText =      103;
  
  static immutable ControlParameters_ControlParameters =   104;
  static immutable ControlParameters_FaceId =              105;
  static immutable ControlParameters_Uri =                 114;
  static immutable ControlParameters_LocalControlFeature = 110;
  static immutable ControlParameters_Origin =              111;
  static immutable ControlParameters_Cost =                106;
  static immutable ControlParameters_Flags =               108;
  static immutable ControlParameters_Strategy =            107;
  static immutable ControlParameters_ExpirationPeriod =    109;
  
  static immutable LocalControlHeader_LocalControlHeader = 80;
  static immutable LocalControlHeader_IncomingFaceId = 81;
  static immutable LocalControlHeader_NextHopFaceId = 82;
  static immutable LocalControlHeader_CachingPolicy = 83;
  static immutable LocalControlHeader_NoCache = 96;
  
  static immutable Link_Preference = 30;
  static immutable Link_Delegation = 31;
}

