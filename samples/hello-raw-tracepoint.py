#!/usr/bin/env python3
from bcc import BPF
import ctypes as ct

# https://docs.kernel.org/trace/events.html
# Tracepoints can be used without creating custom kernel modules
# to register probe functions using the event tracing infrastructure.

# eCHO Episode 74: eBPF Tail Calls
# https://www.youtube.com/watch?v=3qLXw3E0YWg

bpf_text = r"""
#include <linux/sched.h>

int noop() {
    return 0;
}

static int ignore_syscall() {
    return  0;
}

// eBPF tail calls allow for calling a series of functions w/o growing the stack
// BPF_PROG_ARRAY is a map to index eBPF functions
// https://github.com/iovisor/bcc/blob/master/docs/reference_guide.md#10-bpf_prog_array
BPF_PROG_ARRAY(syscall, 300);

// searchable list of syscalls
// https://filippo.io/linux-syscall-table

// https://github.com/iovisor/bcc/blob/master/docs/reference_guide.md#7-raw-tracepoints
RAW_TRACEPOINT_PROBE(sys_enter) {
    // printf() to the common trace_pipe (/sys/kernel/debug/tracing/trace_pipe)
    // https://github.com/iovisor/bcc/blob/master/docs/reference_guide.md#1-bpf_trace_printk
    bpf_trace_printk("syscall");

    // the syscall opcode id is the second argument
    // ctx is hidden by the macro RAW_TRACEPOINT_PROBE
    // https://github.com/torvalds/linux/blob/master/include/trace/events/syscalls.h
    int opcode = ctx->args[1];
    switch (opcode) {
        case 64:
            // eBPF stack only 512 bytes, don't repeat that too often
            ignore_syscall();
            break;
    }

    // perform a "tail call" to another function for each specified opcode
    // the mapping of tail call to opcode is done in userspace
    // func invocation on struct is not proper C, will be translated by BCC
    syscall.call(ctx, opcode);

    // this line will never be evaluated when the tail call succeeds
    bpf_trace_printk("Another syscall: %d", opcode);

    return 0;
}
"""

b = BPF(text=bpf_text)

# fetch the program map
prog_array = b.get_table("syscall")

# map the 64 syscall to the ignore function in the program map
noop_fn = b.load_func("noop", BPF.RAW_TRACEPOINT)
prog_array[ct.c_int(64)] = ct.c_int(noop_fn.fd)

b.trace_print()
