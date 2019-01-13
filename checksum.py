import zlib
source = [192, 168, 0, 50]
dest = [192, 168, 0, 2]
srcmac = [0x00, 0x12, 0x34, 0x56, 0x78, 0x90]
destmac = [0x0c, 0x4d, 0xe9, 0xaa, 0xd4, 0x74]

c1 = 0x0000c53f + (source[0] << 8) + source[1] + (source[2] << 8) + source[3] + (dest[0] <<8) + dest[1] + (dest[2] << 8) + dest[3]
c2 = (c1 & 0x0000ffff) + (c1 >> 16)
c3 = ~((c2 & 0x0000ffff) + (c2 >> 16)) & 0xffffffff

def writehex(f, x):
    f.write("{:02x}\n".format(i))

def replicate(x):
    if x:
        return 0xffffffff
    else:
        return 0
def crc32(frame):
    crc = 0xffffffff
    for byte in frame:
        crc ^= byte
        for i in range(0,8):
            if crc & 1:
                crc = (crc >> 1) ^ 0xedb88320
            else:
                crc = crc >> 1
    crc = crc ^ 0xffffffff
    return [crc & 0xff, (crc >> 8) & 0xff, (crc >> 16) & 0xff, (crc >> 24) & 0xff]


frame = []

with open("frame.hex", "w") as f:
    for i in destmac:
        frame.append(i)
    for i in srcmac:
        frame.append(i)
    for i in [0x08, 0x00, 0x45, 0x00, 0x00, 0x2e, 0x00, 0x00, 0x00, 0x00, 0x80, 0x11]:
        frame.append(i)
    frame.append((c3 >> 8) & 0xff)
    frame.append(c3 & 0xff)
    frame.extend(source)
    frame.extend(dest)

    frame.extend([0x04, 0x00, 0x04, 0x00, 0x00, 0x1a, 0x00, 0x00])

    frame.extend([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17])

    crc = crc32(frame)
    print [hex(x) for x in crc]
    frame.extend(crc)


    f.write("00\n")
    for i in range(0,7):
        f.write("55\n")
    f.write("D5\n")
    for i in frame:
        writehex(f, i)
    written = 9+len(frame)
    for i in range(written, 128):
        f.write("00\n")
