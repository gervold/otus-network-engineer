import re
import csv


def device_id(device):
    """Format: R13, VPC30"""
    return re.findall("\d+", device)[0]


def eth_num(port):
    """Format: e0/1, eth0"""
    return port[-1]


def sort_dev_ids(a, b):
    return (a, b) if a < b else (b, a)


def generate_ipv6(ipv4, provider_asn, link):
    a, b, c, d = ipv4.split('.')
    dev1, int1, _, int2, dev2 = link.split(' ')
    print(dev1, dev2)
    # ipv6 = f"2001:{asn}:{device}:{port}:"+":".join([a, b, c, d])
    first_dev, second_dev = sort_dev_ids(device_id(dev1), device_id(dev2))
    position = 1 if device_id(dev1) == first_dev else 2
    if a == '10' and b == '0': # 10.0/16
        ipv6 = f"2001:0:{first_dev}:{second_dev}::{position}"  # internal
    else:
        ipv6 = f"2001:{provider_asn}:{first_dev}:{second_dev}::{position}"  # external
    link_local = "FE80::" + d
    return ipv6, link_local


if __name__ == "__main__":
    PROVIDER_ASN = 1001
    fname = "msk.csv"
    reader = csv.reader(open(fname))

    # read and generate ipv6
    header = next(reader)
    rows = []
    for row in reader:
        device, port, ipv4, ipv6, vlan, link, comment = row
        if ('R' in device or 'VPC' in device) and ipv4 != "":
            ipv6, link_local = generate_ipv6(ipv4, PROVIDER_ASN, link)
            ipv6 = ipv6 # + "<br>" + link_local
        rows.append([device, port, ipv4, ipv6, vlan, link, comment])

    print(rows)

    # save
    with open("out_"+fname, "w") as out:
        writer = csv.writer(out)
        writer.writerow(header)
        writer.writerows(rows)