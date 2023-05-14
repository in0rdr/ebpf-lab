#include <linux/bpf.h>
// sections, printk, license, etc.
#include <bpf/bpf_helpers.h>
// bpf_ntohs
#include <bpf/bpf_endian.h>
// struct ethhdr
#include <linux/if_ether.h>
// struct iphdr
#include <linux/ip.h>

// https://github.com/lizrice/learning-ebpf/blob/main/chapter8

// XDP type of BPF program
SEC("xdp")

int hello_xdp(struct xdp_md *ctx) {
  // helper macro to print out debug messages, wrapper for bpf_trace_printk()
  // /usr/include/bpf/bpf_helpers.h
  bpf_printk("received packet");
  // XDP_PASS      : let the packet pass
  // XDP_DROP      : you shall not pass
  // XDP_TC        : send packet back through the interface it came through
  // XDP_REDIRECT  : send packet to different interface

  // Parse xdp packet and detect request type/protocol
  int protocol = 0;

  // pointers to start and end of packet in memory
  void* data = (void*)(long)ctx->data;
  void* data_end = (void*)(long)ctx->data_end;

  // start of ethernet header
  // /usr/include/linux/if_ether.h
  // we could already lookup dest/source here
  struct ethhdr* eth = data;

  // check that packet is big enough for entire ethernet header
  if (data + sizeof(struct ethhdr) > data_end)
  // try to check this falsely and the verifiy will shout at you during bptool
  // prog load (offset is outside of the packet)
  //if (data + sizeof(struct ethhdr) <= data_end)
    return XDP_DROP;

  // check that it's an IP packet
  // bpf_ntohs is a bpf helper
  if (bpf_ntohs(eth->h_proto) != ETH_P_IP)
    return XDP_DROP;

  // start address of IP header
  struct iphdr* iph = data + sizeof(struct ethhdr);

  // check that entire header fits the packet
  if (data + sizeof(struct ethhdr) + sizeof(struct iphdr) > data_end)
    return XDP_DROP;

  // fetch protocol type from IP header
  // /usr/include/linux/ip.h
  protocol = iph->protocol;

  if (protocol == 1) {
    // ICMP
    bpf_printk("dropping ICMP packet");
    return XDP_DROP;
  }
  return XDP_PASS;
}

// cannot call GPL-restricted functions (e.g., bpf_trace_printk) from non-GPL
// compatible program
char LICENSE[] SEC("license") = "GPL";

