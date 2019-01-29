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
	{ 0x4150082b, __VMLINUX_SYMBOL_STR(skb_queue_head) },
	{ 0x3356b90b, __VMLINUX_SYMBOL_STR(cpu_tss) },
	{ 0x18e60984, __VMLINUX_SYMBOL_STR(__do_once_start) },
	{ 0x92a94ad2, __VMLINUX_SYMBOL_STR(kmalloc_caches) },
	{ 0xd2b09ce5, __VMLINUX_SYMBOL_STR(__kmalloc) },
	{ 0xe4689576, __VMLINUX_SYMBOL_STR(ktime_get_with_offset) },
	{ 0x924e7abd, __VMLINUX_SYMBOL_STR(sock_setsockopt) },
	{ 0x51f9d88a, __VMLINUX_SYMBOL_STR(sockfd_lookup) },
	{ 0x8437c918, __VMLINUX_SYMBOL_STR(__ip_route_output_key_hash) },
	{ 0x6bf1c17f, __VMLINUX_SYMBOL_STR(pv_lock_ops) },
	{ 0x754d539c, __VMLINUX_SYMBOL_STR(strlen) },
	{ 0xbab64eb8, __VMLINUX_SYMBOL_STR(exanic_netdev_intercept_remove) },
	{ 0x219aa30d, __VMLINUX_SYMBOL_STR(remap_vmalloc_range) },
	{ 0x43a53735, __VMLINUX_SYMBOL_STR(__alloc_workqueue_key) },
	{ 0xf68285c0, __VMLINUX_SYMBOL_STR(register_inetaddr_notifier) },
	{ 0xdb4eac0d, __VMLINUX_SYMBOL_STR(genl_unregister_family) },
	{ 0x3da22aa6, __VMLINUX_SYMBOL_STR(vlan_dev_vlan_id) },
	{ 0x79aa04a2, __VMLINUX_SYMBOL_STR(get_random_bytes) },
	{ 0xd4f23d35, __VMLINUX_SYMBOL_STR(arp_tbl) },
	{ 0x5e2f4782, __VMLINUX_SYMBOL_STR(dst_release) },
	{ 0xd9d3bcd3, __VMLINUX_SYMBOL_STR(_raw_spin_lock_bh) },
	{ 0x6b06fdce, __VMLINUX_SYMBOL_STR(delayed_work_timer_fn) },
	{ 0xf0f7dff1, __VMLINUX_SYMBOL_STR(get_task_comm) },
	{ 0x6dc0c9dc, __VMLINUX_SYMBOL_STR(down_interruptible) },
	{ 0xd042917d, __VMLINUX_SYMBOL_STR(__dev_kfree_skb_any) },
	{ 0x9580deb, __VMLINUX_SYMBOL_STR(init_timer_key) },
	{ 0xa57863e, __VMLINUX_SYMBOL_STR(cancel_delayed_work_sync) },
	{ 0x7d9cc03b, __VMLINUX_SYMBOL_STR(mutex_unlock) },
	{ 0x440083a0, __VMLINUX_SYMBOL_STR(__genl_register_family) },
	{ 0x999e8297, __VMLINUX_SYMBOL_STR(vfree) },
	{ 0x4af2d35a, __VMLINUX_SYMBOL_STR(neigh_destroy) },
	{ 0x7d11c268, __VMLINUX_SYMBOL_STR(jiffies) },
	{ 0x5bad0436, __VMLINUX_SYMBOL_STR(skb_trim) },
	{ 0xd08caf9c, __VMLINUX_SYMBOL_STR(__neigh_event_send) },
	{ 0x4f8b5ddb, __VMLINUX_SYMBOL_STR(_copy_to_user) },
	{ 0xf7e32b63, __VMLINUX_SYMBOL_STR(skb_dequeue_tail) },
	{ 0x11517817, __VMLINUX_SYMBOL_STR(misc_register) },
	{ 0x706d051c, __VMLINUX_SYMBOL_STR(del_timer_sync) },
	{ 0xa097058, __VMLINUX_SYMBOL_STR(skb_queue_purge) },
	{ 0xdb3bcca6, __VMLINUX_SYMBOL_STR(cancel_delayed_work) },
	{ 0x82500e39, __VMLINUX_SYMBOL_STR(from_kuid) },
	{ 0x1916e38c, __VMLINUX_SYMBOL_STR(_raw_spin_unlock_irqrestore) },
	{ 0x391afe42, __VMLINUX_SYMBOL_STR(current_task) },
	{ 0xaf69df35, __VMLINUX_SYMBOL_STR(__mutex_init) },
	{ 0x27e1a049, __VMLINUX_SYMBOL_STR(printk) },
	{ 0x1250c7e1, __VMLINUX_SYMBOL_STR(_raw_spin_trylock) },
	{ 0x449ad0a7, __VMLINUX_SYMBOL_STR(memcmp) },
	{ 0x8afaebe7, __VMLINUX_SYMBOL_STR(nla_put) },
	{ 0x4fe1eddf, __VMLINUX_SYMBOL_STR(unregister_netevent_notifier) },
	{ 0x16305289, __VMLINUX_SYMBOL_STR(warn_slowpath_null) },
	{ 0xb7964e0, __VMLINUX_SYMBOL_STR(skb_push) },
	{ 0xbf97e500, __VMLINUX_SYMBOL_STR(mutex_lock) },
	{ 0x8c03d20c, __VMLINUX_SYMBOL_STR(destroy_workqueue) },
	{ 0xda805034, __VMLINUX_SYMBOL_STR(dev_get_by_index) },
	{ 0x6dc6dd56, __VMLINUX_SYMBOL_STR(down) },
	{ 0xc2cdbf1, __VMLINUX_SYMBOL_STR(synchronize_sched) },
	{ 0x16e5c2a, __VMLINUX_SYMBOL_STR(mod_timer) },
	{ 0xe87cac95, __VMLINUX_SYMBOL_STR(netlink_unicast) },
	{ 0xa735db59, __VMLINUX_SYMBOL_STR(prandom_u32) },
	{ 0xb5277b74, __VMLINUX_SYMBOL_STR(init_net) },
	{ 0x9e2c81e8, __VMLINUX_SYMBOL_STR(fput) },
	{ 0x42160169, __VMLINUX_SYMBOL_STR(flush_workqueue) },
	{ 0x414b06e1, __VMLINUX_SYMBOL_STR(vlan_dev_real_dev) },
	{ 0x5ed4bec2, __VMLINUX_SYMBOL_STR(__alloc_skb) },
	{ 0xfe029963, __VMLINUX_SYMBOL_STR(unregister_inetaddr_notifier) },
	{ 0xbba70a2d, __VMLINUX_SYMBOL_STR(_raw_spin_unlock_bh) },
	{ 0x70cd1f, __VMLINUX_SYMBOL_STR(queue_delayed_work_on) },
	{ 0x5635a60a, __VMLINUX_SYMBOL_STR(vmalloc_user) },
	{ 0xdb7305a1, __VMLINUX_SYMBOL_STR(__stack_chk_fail) },
	{ 0xa202a8e5, __VMLINUX_SYMBOL_STR(kmalloc_order_trace) },
	{ 0x4bc955f4, __VMLINUX_SYMBOL_STR(kfree_skb) },
	{ 0xbdfb6dbb, __VMLINUX_SYMBOL_STR(__fentry__) },
	{ 0x81fcd7c8, __VMLINUX_SYMBOL_STR(kmem_cache_alloc_trace) },
	{ 0xe259ae9e, __VMLINUX_SYMBOL_STR(_raw_spin_lock) },
	{ 0x680ec266, __VMLINUX_SYMBOL_STR(_raw_spin_lock_irqsave) },
	{ 0x37a0cba, __VMLINUX_SYMBOL_STR(kfree) },
	{ 0x69acdf38, __VMLINUX_SYMBOL_STR(memcpy) },
	{ 0x67db0697, __VMLINUX_SYMBOL_STR(genlmsg_put) },
	{ 0x78e739aa, __VMLINUX_SYMBOL_STR(up) },
	{ 0xb8776414, __VMLINUX_SYMBOL_STR(fget) },
	{ 0xb08dd3f4, __VMLINUX_SYMBOL_STR(exanic_netdev_intercept_add) },
	{ 0xe113bbbc, __VMLINUX_SYMBOL_STR(csum_partial) },
	{ 0x4761f17c, __VMLINUX_SYMBOL_STR(register_netevent_notifier) },
	{ 0x64a71dc1, __VMLINUX_SYMBOL_STR(skb_put) },
	{ 0x4f6b400b, __VMLINUX_SYMBOL_STR(_copy_from_user) },
	{ 0x1d1c3716, __VMLINUX_SYMBOL_STR(__nlmsg_put) },
	{ 0x712c3460, __VMLINUX_SYMBOL_STR(misc_deregister) },
	{ 0x6310f797, __VMLINUX_SYMBOL_STR(exanic_transmit_frame) },
	{ 0x85e1f1, __VMLINUX_SYMBOL_STR(__do_once_done) },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=exanic";


MODULE_INFO(srcversion, "3D9E230BB36464384A2D2F1");
