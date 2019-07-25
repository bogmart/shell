#!/usr/bin/python

from logging import getLogger, ERROR
getLogger('scapy.runtime').setLevel(ERROR)

from threading import Thread
from md5 import md5
from socket import *
from struct import *
from time import sleep
from optparse import OptionParser
from scapy.all import get_if_hwaddr

ETHERTYPE_PAE = 0x888e
PAE_GROUP_ADDR = '\x01\x80\xc2\x00\x00\x03'

EAPOL_VERSION = 2
EAPOL_START = 1
EAPOL_LOGOFF = 2
EAPOL_EAPPACKET = 0

EAP_REQUEST = 1
EAP_RESPONSE = 2
EAP_SUCCESS = 3
EAP_FAILURE = 4
EAP_TYPE_ID = 1
EAP_TYPE_MD5 = 4

LLDP_ADDR = '\x01\x80\xc2\x00\x00\x0e'

LLDP_LOAD_1 = '\x88\xcc\x02\x06\x05\x01\x0a\x0a\x00'
LLDP_LOAD_2 = '\x04\x10\x07\x30\x30\x32\x31\x35\x35\x35\x33\x41\x42\x36\x44\x3a\x50\x31\x06\x02\x00\xb4\x08\x07\x53\x57\x20\x50\x4f\x52\x54\x0a\x0f\x53\x45\x50\x30\x30\x32\x31\x35\x35\x35\x33\x41\x42\x36\x44\x0c\x25\x43\x69\x73\x63\x6f\x20\x49\x50\x20\x50\x68\x6f\x6e\x65\x20\x37\x39\x31\x31\x47\x2c\x56\x35\x2c\x20\x53\x49\x50\x31\x31\x2e\x39\x2d\x30\x2d\x33\x53\x0e\x04\x00\x24\x00\x24\x10\x0c\x05\x01\x0a\x0a\x00\x8c\x01\x00\x00\x00\x00\x00\xfe\x09\x00\x12\x0f\x01\x03\x00\x36\x00\x0f\xfe\x07\x00\x12\xbb\x01\x00\x33\x03\xfe\x08\x00\x12\xbb\x02\x01'
LLDP_LOAD_3 = '\xfe\x08\x00\x12\xbb\x02\x02'
LLDP_LOAD_4 = '\xfe\x07\x00\x12\xbb\x04\x40\x00\x32\xfe\x05\x00\x12\xbb\x05\x35\xfe\x16\x00\x12\xbb\x06\x74\x6e\x70\x31\x31\x2e\x33\x2d\x30\x2d\x31\x2d\x33\x31\x2e\x62\x69\x6e\xfe\x10\x00\x12\xbb\x07\x53\x49\x50\x31\x31\x2e\x39\x2d\x30\x2d\x33\x53\xfe\x0f\x00\x12\xbb\x08\x46\x43\x48\x31\x32\x31\x36\x45\x35\x32\x56\xfe\x17\x00\x12\xbb\x09\x43\x69\x73\x63\x6f\x20\x53\x79\x73\x74\x65\x6d\x73\x2c\x20\x49\x6e\x63\x2e\xfe\x0c\x00\x12\xbb\x0a\x43\x50\x2d\x37\x39\x31\x31\x47\xfe\x04\x00\x12\xbb\x0b\x00\x00'

TH_LIST = []

parser = OptionParser()

parser.add_option('-c', '--count', action = 'store', default = 1, type = 'int', dest = 'count', help = 'number of clients')
parser.add_option('-v', '--voice_vlan', action = 'store', default = None, type = 'int', dest = 'voice_vlan', help = 'if there is a voip phone, specify voice vlan')
parser.add_option('-m', '--mac', action = 'store', default = None, type = 'str', dest = 'mac', help = 'first mac address')
parser.add_option('-u', '--user', action = 'store', default = 'user', type = 'str', dest = 'USER', help = 'RADIUS username')
parser.add_option('-p', '--pass', action = 'store', default = 'pass', type = 'str', dest = 'PASS', help = 'RADIUS password')
parser.add_option('-d', '--dev', action = 'store', default = 'eth1', type = 'str', dest = 'DEV', help = 'ethernet device')
parser.add_option('-f', '--flag', action = 'store', default = None, type = 'int', dest = 'flag', help = 'disconnect flag True=1')

(options, args) = parser.parse_args()

def EAPOL(type, payload = ''):
    return pack('!BBH', EAPOL_VERSION, type, len(payload))+payload

def EAP(code, id, type = 0, data = ''):
    if code in [EAP_SUCCESS, EAP_FAILURE]:
        return pack('!BBH', code, id, 4)
    else:
        return pack('!BBHB', code, id, 5 + len(data), type) + data

def ethernet_header(src, dst, type):
    return dst + src + pack('!H', type)

def lldp(dst, vlan, ip):
    a = str(bin(vlan)[2:])
    for i in range(0, 12 - len(bin(vlan)[2:])): a = '0' + a
    a = '010' + a + '101101110'
    c = 0
    d = ''
    l = [a[0:8],a[8:16],a[16:]]
    for j in range(0,3):
        i = 0
        b = True
        while b:
            if l[j][i] == '1':
                c += 2**(7-i)
            if i < 7:
                i += 1
            else:
                d += pack('B', c)
                c = 0
                b = False
    return LLDP_ADDR + dst + LLDP_LOAD_1 + pack('B', ip + 1) + LLDP_LOAD_2 + d + LLDP_LOAD_3 + d + LLDP_LOAD_4

def mac_gen(i):
    if options.mac == None:
        mac = get_if_hwaddr(options.DEV)
    else:
        mac = options.mac
    mac = list(''.join(['%s' % pack('B', int(j, 16)) for j in mac.split(':')]))
    mac[5] = str(pack('B', unpack('B', mac[5])[0] + i))
    return ''.join(mac)

def mac_unpack(mac):
    return ':'.join(['%.2x' % unpack('B', j) for j in mac])

class dot1x(Thread):

    def __init__(self, i):
        Thread.__init__(self)
        self.i = i

    def run(self):
        b = False
        s = socket(AF_PACKET, SOCK_RAW, htons(ETHERTYPE_PAE))
        s.bind((options.DEV, ETHERTYPE_PAE))
        mymac = mac_gen(self.i)
        llhead = ethernet_header(mymac, PAE_GROUP_ADDR, ETHERTYPE_PAE)
        if options.flag != 1:
            if options.voice_vlan != None:
                s.send(lldp(mymac, options.voice_vlan, self.i))
                print '> sent LLDP frame for mac ' + mac_unpack(mymac)
            s.send(llhead + EAPOL(EAPOL_START))
            print '> sent EAPOL start for mac ' + mac_unpack(mymac)
        while True:
            if options.flag == 1:
                s.send(llhead + EAPOL(EAPOL_LOGOFF))
                print '> sent EAPOL logoff for mac ' + mac_unpack(mymac)
                break
            if b and options.voice_vlan != None:
                s.send(lldp(mymac, options.voice_vlan, self.i))
                print '> sent LLDP frame for mac ' + mac_unpack(mymac)
                sleep(30)
                p = ''
            else:
                p = s.recv(1600)
            if p[0:6] == mymac:
#            if True:
                vers, type, eapollen = unpack('!BBH', p[14:18])
                if type == EAPOL_EAPPACKET:
                    code, id = unpack('!BB', p[18:20])
                    if code == EAP_SUCCESS:
                        b = True
                        print '< rcvd EAP success for mac ' + mac_unpack(mymac) + '\n'
                    elif code == EAP_FAILURE:
                        print '< rcvd EAP failure for mac ' + mac_unpack(mymac) + '\n'
                    elif code == EAP_RESPONSE:
                        print '< rcvd EAP response ... ignoring'
                    elif code == EAP_REQUEST:
                        reqtype, reqsize = unpack('!BB', p[22:24])
                        reqdata = p[24:24 + reqsize]
                        if reqtype == EAP_TYPE_ID:
                            print '< rcvd EAP request for ID for mac ' + mac_unpack(mymac)
                            s.send(llhead + EAPOL(EAPOL_EAPPACKET, EAP(EAP_RESPONSE, id, reqtype, options.USER)))
                            print '> sent EAP response with ID "%s" for mac ' % options.USER + mac_unpack(mymac)
                        elif reqtype == EAP_TYPE_MD5:
                            print '< rcvd EAP request for MD5 for mac ' + mac_unpack(mymac)
                            challenge = pack('!B', id) + options.PASS + reqdata
                            resp = md5(challenge).digest()
                            resp = chr(len(resp)) + resp
                            s.send(llhead + EAPOL(EAPOL_EAPPACKET, EAP(EAP_RESPONSE, id, reqtype, resp)))
                            print '> sent EAP response with MD5 for mac ' + mac_unpack(mymac)
                        else:
                            print '< rcvd unknown Req type ... ignoring'
                    else:
                        print '< rcvd unknown EAP code ... ignoring'
                else:
                    print '< rcvd rcvd EAPOL type %i' %type

for i in range(options.count):
    th = dot1x(i)
    th.start()
    TH_LIST.append(th)
#   sleep(3)

try:
    while True:
        sleep(1)
except KeyboardInterrupt:
    for th in TH_LIST:
        Thread._Thread__stop(th)
    print ' - bye'
