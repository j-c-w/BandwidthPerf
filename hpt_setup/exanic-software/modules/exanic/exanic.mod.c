#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

MODULE_INFO(vermagic, VERMAGIC_STRING);

__visible struct module __this_module
__attribute__((section(".gnu.linkonce.this_module"))) = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

static const struct modversion_info ____versions[]
__used
__attribute__((section("__versions"))) = {
	{ 0xc6c01fa, __VMLINUX_SYMBOL_STR(module_layout) },
	{ 0x2d3385d3, __VMLINUX_SYMBOL_STR(system_wq) },
	{ 0x402b8281, __VMLINUX_SYMBOL_STR(__request_module) },
	{ 0xbde65608, __VMLINUX_SYMBOL_STR(netdev_info) },
	{ 0x92a94ad2, __VMLINUX_SYMBOL_STR(kmalloc_caches) },
	{ 0xd2b09ce5, __VMLINUX_SYMBOL_STR(__kmalloc) },
	{ 0xf9a482f9, __VMLINUX_SYMBOL_STR(msleep) },
	{ 0xe6da44a, __VMLINUX_SYMBOL_STR(set_normalized_timespec) },
	{ 0x6bf1c17f, __VMLINUX_SYMBOL_STR(pv_lock_ops) },
	{ 0x1e0c2be4, __VMLINUX_SYMBOL_STR(ioremap_wc) },
	{ 0x16abfc10, __VMLINUX_SYMBOL_STR(param_ops_int) },
	{ 0x1e4663cd, __VMLINUX_SYMBOL_STR(napi_disable) },
	{ 0x219aa30d, __VMLINUX_SYMBOL_STR(remap_vmalloc_range) },
	{ 0xd2d1927b, __VMLINUX_SYMBOL_STR(hrtimer_forward) },
	{ 0xa50a80c2, __VMLINUX_SYMBOL_STR(boot_cpu_data) },
	{ 0xd17fbaf3, __VMLINUX_SYMBOL_STR(pci_disable_device) },
	{ 0xe418fde4, __VMLINUX_SYMBOL_STR(hrtimer_cancel) },
	{ 0x251f6614, __VMLINUX_SYMBOL_STR(ktime_get_snapshot) },
	{ 0x1846825f, __VMLINUX_SYMBOL_STR(netif_carrier_on) },
	{ 0xb7eb0c3d, __VMLINUX_SYMBOL_STR(netif_carrier_off) },
	{ 0xc87c1f84, __VMLINUX_SYMBOL_STR(ktime_get) },
	{ 0xeae3dfd6, __VMLINUX_SYMBOL_STR(__const_udelay) },
	{ 0x323a933d, __VMLINUX_SYMBOL_STR(pci_release_regions) },
	{ 0x9580deb, __VMLINUX_SYMBOL_STR(init_timer_key) },
	{ 0x7d9cc03b, __VMLINUX_SYMBOL_STR(mutex_unlock) },
	{ 0x999e8297, __VMLINUX_SYMBOL_STR(vfree) },
	{ 0xf4c91ed, __VMLINUX_SYMBOL_STR(ns_to_timespec) },
	{ 0x7d11c268, __VMLINUX_SYMBOL_STR(jiffies) },
	{ 0x414e954d, __VMLINUX_SYMBOL_STR(param_ops_string) },
	{ 0xcd262071, __VMLINUX_SYMBOL_STR(__netdev_alloc_skb) },
	{ 0x381520cd, __VMLINUX_SYMBOL_STR(ptp_clock_unregister) },
	{ 0x4f8b5ddb, __VMLINUX_SYMBOL_STR(_copy_to_user) },
	{ 0x48254905, __VMLINUX_SYMBOL_STR(pci_set_master) },
	{ 0x50d1f870, __VMLINUX_SYMBOL_STR(pgprot_writecombine) },
	{ 0x11517817, __VMLINUX_SYMBOL_STR(misc_register) },
	{ 0x8ee44df6, __VMLINUX_SYMBOL_STR(ptp_clock_event) },
	{ 0x706d051c, __VMLINUX_SYMBOL_STR(del_timer_sync) },
	{ 0xd45ea32f, __VMLINUX_SYMBOL_STR(hrtimer_start_range_ns) },
	{ 0xfb578fc5, __VMLINUX_SYMBOL_STR(memset) },
	{ 0xe659a8c5, __VMLINUX_SYMBOL_STR(pci_enable_pcie_error_reporting) },
	{ 0xf15e6c6b, __VMLINUX_SYMBOL_STR(dev_err) },
	{ 0x1916e38c, __VMLINUX_SYMBOL_STR(_raw_spin_unlock_irqrestore) },
	{ 0xaf69df35, __VMLINUX_SYMBOL_STR(__mutex_init) },
	{ 0x27e1a049, __VMLINUX_SYMBOL_STR(printk) },
	{ 0x20c55ae0, __VMLINUX_SYMBOL_STR(sscanf) },
	{ 0x4c9d28b0, __VMLINUX_SYMBOL_STR(phys_base) },
	{ 0x479c3c86, __VMLINUX_SYMBOL_STR(find_next_zero_bit) },
	{ 0x11ec5e3, __VMLINUX_SYMBOL_STR(free_netdev) },
	{ 0x9166fada, __VMLINUX_SYMBOL_STR(strncpy) },
	{ 0x62e4100, __VMLINUX_SYMBOL_STR(register_netdev) },
	{ 0xc0a8fc2d, __VMLINUX_SYMBOL_STR(netif_receive_skb) },
	{ 0x5792f848, __VMLINUX_SYMBOL_STR(strlcpy) },
	{ 0x16305289, __VMLINUX_SYMBOL_STR(warn_slowpath_null) },
	{ 0xbf97e500, __VMLINUX_SYMBOL_STR(mutex_lock) },
	{ 0x16e5c2a, __VMLINUX_SYMBOL_STR(mod_timer) },
	{ 0x924fc613, __VMLINUX_SYMBOL_STR(netif_napi_add) },
	{ 0x9536b0aa, __VMLINUX_SYMBOL_STR(ptp_clock_register) },
	{ 0x2072ee9b, __VMLINUX_SYMBOL_STR(request_threaded_irq) },
	{ 0x42160169, __VMLINUX_SYMBOL_STR(flush_workqueue) },
	{ 0x320c8dff, __VMLINUX_SYMBOL_STR(vm_insert_page) },
	{ 0xb0a19973, __VMLINUX_SYMBOL_STR(arch_dma_alloc_attrs) },
	{ 0xfd75cb0, __VMLINUX_SYMBOL_STR(_dev_info) },
	{ 0x78764f4e, __VMLINUX_SYMBOL_STR(pv_irq_ops) },
	{ 0x36d4b0f5, __VMLINUX_SYMBOL_STR(pci_disable_link_state) },
	{ 0x618911fc, __VMLINUX_SYMBOL_STR(numa_node) },
	{ 0x42c8de35, __VMLINUX_SYMBOL_STR(ioremap_nocache) },
	{ 0x3b886de8, __VMLINUX_SYMBOL_STR(__napi_schedule) },
	{ 0x5944d015, __VMLINUX_SYMBOL_STR(__cachemode2pte_tbl) },
	{ 0x5635a60a, __VMLINUX_SYMBOL_STR(vmalloc_user) },
	{ 0xdb7305a1, __VMLINUX_SYMBOL_STR(__stack_chk_fail) },
	{ 0xadfdfcef, __VMLINUX_SYMBOL_STR(__bitmap_andnot) },
	{ 0x43f47e07, __VMLINUX_SYMBOL_STR(napi_complete_done) },
	{ 0x17cf49e, __VMLINUX_SYMBOL_STR(eth_type_trans) },
	{ 0xbdfb6dbb, __VMLINUX_SYMBOL_STR(__fentry__) },
	{ 0xa97d4a9c, __VMLINUX_SYMBOL_STR(netdev_err) },
	{ 0x9e308128, __VMLINUX_SYMBOL_STR(pci_enable_msi_range) },
	{ 0x7d0571e5, __VMLINUX_SYMBOL_STR(pci_unregister_driver) },
	{ 0x81fcd7c8, __VMLINUX_SYMBOL_STR(kmem_cache_alloc_trace) },
	{ 0x61fb248a, __VMLINUX_SYMBOL_STR(node_states) },
	{ 0xe259ae9e, __VMLINUX_SYMBOL_STR(_raw_spin_lock) },
	{ 0xdf64d62d, __VMLINUX_SYMBOL_STR(__dynamic_dev_dbg) },
	{ 0x680ec266, __VMLINUX_SYMBOL_STR(_raw_spin_lock_irqsave) },
	{ 0x635a4d29, __VMLINUX_SYMBOL_STR(pci_disable_pcie_error_reporting) },
	{ 0x37a0cba, __VMLINUX_SYMBOL_STR(kfree) },
	{ 0x1ad4834e, __VMLINUX_SYMBOL_STR(remap_pfn_range) },
	{ 0x69acdf38, __VMLINUX_SYMBOL_STR(memcpy) },
	{ 0x2c1c1039, __VMLINUX_SYMBOL_STR(pci_request_regions) },
	{ 0xf2ca1011, __VMLINUX_SYMBOL_STR(ptp_clock_index) },
	{ 0x3661d267, __VMLINUX_SYMBOL_STR(pci_disable_msi) },
	{ 0x2b9e8aac, __VMLINUX_SYMBOL_STR(dma_supported) },
	{ 0x83ba5fbb, __VMLINUX_SYMBOL_STR(hrtimer_init) },
	{ 0xedc03953, __VMLINUX_SYMBOL_STR(iounmap) },
	{ 0x4203c482, __VMLINUX_SYMBOL_STR(__pci_register_driver) },
	{ 0x7cbab064, __VMLINUX_SYMBOL_STR(unregister_netdev) },
	{ 0x28318305, __VMLINUX_SYMBOL_STR(snprintf) },
	{ 0x420ffece, __VMLINUX_SYMBOL_STR(consume_skb) },
	{ 0x2e542d3c, __VMLINUX_SYMBOL_STR(pci_enable_device_mem) },
	{ 0x796e48e5, __VMLINUX_SYMBOL_STR(skb_tstamp_tx) },
	{ 0x64a71dc1, __VMLINUX_SYMBOL_STR(skb_put) },
	{ 0x745ac478, __VMLINUX_SYMBOL_STR(devm_kmalloc) },
	{ 0x4f6b400b, __VMLINUX_SYMBOL_STR(_copy_from_user) },
	{ 0x36c8811, __VMLINUX_SYMBOL_STR(param_ops_uint) },
	{ 0x712c3460, __VMLINUX_SYMBOL_STR(misc_deregister) },
	{ 0xbbd78bd4, __VMLINUX_SYMBOL_STR(dma_ops) },
	{ 0xf20dabd8, __VMLINUX_SYMBOL_STR(free_irq) },
	{ 0x363cd1b7, __VMLINUX_SYMBOL_STR(alloc_etherdev_mqs) },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=ptp";

MODULE_ALIAS("pci:v000010EEd00002B00sv*sd*bc*sc*i*");
MODULE_ALIAS("pci:v00001CE4d00000001sv*sd*bc*sc*i*");
MODULE_ALIAS("pci:v00001CE4d00000002sv*sd*bc*sc*i*");
MODULE_ALIAS("pci:v00001CE4d00000003sv*sd*bc*sc*i*");
MODULE_ALIAS("pci:v00001CE4d00000004sv*sd*bc*sc*i*");
MODULE_ALIAS("pci:v00001CE4d00000005sv*sd*bc*sc*i*");
MODULE_ALIAS("pci:v00001CE4d00000006sv*sd*bc*sc*i*");
MODULE_ALIAS("pci:v00001CE4d00000007sv*sd*bc*sc*i*");
MODULE_ALIAS("pci:v00001CE4d00000008sv*sd*bc*sc*i*");
MODULE_ALIAS("pci:v00001CE4d00000009sv*sd*bc*sc*i*");

MODULE_INFO(srcversion, "5627A637D3E7745813C156E");
