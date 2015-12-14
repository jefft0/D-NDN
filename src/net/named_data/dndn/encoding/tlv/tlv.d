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
  immutable Interest =         5;
  immutable Data =             6;
  immutable Name =             7;
  immutable NameComponent =    8;
  immutable Selectors =        9;
  immutable Nonce =            10;
  // immutable <Unassigned> =  11;
  immutable InterestLifetime = 12;
  immutable MinSuffixComponents = 13;
  immutable MaxSuffixComponents = 14;
  immutable PublisherPublicKeyLocator = 15;
  immutable Exclude =          16;
  immutable ChildSelector =    17;
  immutable MustBeFresh =      18;
  immutable Any =              19;
  immutable MetaInfo =         20;
  immutable Content =          21;
  immutable SignatureInfo =    22;
  immutable SignatureValue =   23;
  immutable ContentType =      24;
  immutable FreshnessPeriod =  25;
  immutable FinalBlockId =     26;
  immutable SignatureType =    27;
  immutable KeyLocator =       28;
  immutable KeyLocatorDigest = 29;
  immutable SelectedDelegation = 32;
  immutable FaceInstance =     128;
  immutable ForwardingEntry =  129;
  immutable StatusResponse =   130;
  immutable Action =           131;
  immutable FaceID =           132;
  immutable IPProto =          133;
  immutable Host =             134;
  immutable Port =             135;
  immutable MulticastInterface = 136;
  immutable MulticastTTL =     137;
  immutable ForwardingFlags =  138;
  immutable StatusCode =       139;
  immutable StatusText =       140;
  
  immutable SignatureType_DigestSha256 = 0;
  immutable SignatureType_SignatureSha256WithRsa = 1;
  immutable SignatureType_SignatureSha256WithEcdsa = 3;
  
  immutable ContentType_Default = 0;
  immutable ContentType_Link = 1;
  immutable ContentType_Key = 2;
  
  immutable NfdCommand_ControlResponse = 101;
  immutable NfdCommand_StatusCode =      102;
  immutable NfdCommand_StatusText =      103;
  
  immutable ControlParameters_ControlParameters =   104;
  immutable ControlParameters_FaceId =              105;
  immutable ControlParameters_Uri =                 114;
  immutable ControlParameters_LocalControlFeature = 110;
  immutable ControlParameters_Origin =              111;
  immutable ControlParameters_Cost =                106;
  immutable ControlParameters_Flags =               108;
  immutable ControlParameters_Strategy =            107;
  immutable ControlParameters_ExpirationPeriod =    109;
  
  immutable LocalControlHeader_LocalControlHeader = 80;
  immutable LocalControlHeader_IncomingFaceId = 81;
  immutable LocalControlHeader_NextHopFaceId = 82;
  immutable LocalControlHeader_CachingPolicy = 83;
  immutable LocalControlHeader_NoCache = 96;
  
  immutable Link_Preference = 30;
  immutable Link_Delegation = 31;
}

