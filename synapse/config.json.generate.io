cat << CTAG
{
	name:I/O,
		elements:[
			{ STitleBar:{
				title:"I/O Control"
			}},
				{ SSeekBar:{
					title:"Read-ahead Size",
					description:"Set the read-ahead size for the internal storage.",
					unit:" KB",
					step:128,
					min:128,
					max:4096,
					default:`$BB cat /sys/block/mmcblk0/queue/read_ahead_kb`,
					action:"ioset queue read_ahead_kb"
				}},
				{ SOptionList:{
					title:"I/O Scheduler",
					description:"The I/O Scheduler decides how to prioritize and handle I/O requests. More info: <a href='http://timos.me/tm/wiki/ioscheduler'>HERE</a>",
					default:`$BB echo $($UKM/actions/bracket-option \`sh $DEVICE DirIOScheduler\`)`,
					action:"ioset scheduler",
					values:[
						`sh $DEVICE IOSchedulerList`
					],
					notify:[
						{
							on:APPLY,
							do:[ REFRESH, CANCEL ],
							to:"`sh $DEVICE DirIOSchedulerTree`"
						},
						{
							on:REFRESH,
							do:REFRESH,
							to:"`sh $DEVICE DirIOSchedulerTree`"
						}
					]
				}},
				`if [ -f "/sys/module/mmc_core/parameters/use_spi_crc" ]; then
				CRCS=\`bool /sys/module/mmc_core/parameters/use_spi_crc\`
					$BB echo '{ SPane:{
						title:"Software CRC control"
					}},
						{ SCheckBox:{
							label:"Software CRC control",
							description:"Enabling software CRCs on the data blocks can be a significant (30%) performance cost. So we allow it to be disabled.",
							default:'$CRCS',
							action:"boolean /sys/module/mmc_core/parameters/use_spi_crc"
						}},'
				fi`
				`if [ -f "/sys/devices/msm_sdcc.1/mmc_host/mmc0/clk_scaling/scale_down_in_low_wr_load" ]; then
				MMCC=\`$BB cat /sys/devices/msm_sdcc.1/mmc_host/mmc0/clk_scaling/scale_down_in_low_wr_load\`
				$BB echo '{ SPane:{
					title:"Memory Card Clock Scaling Control"
				}},
					{ SCheckBox:{
						label:"MMC Clock Scaling Control",
						description:"Optimize clock scaling during write requests. The default value for it is 0. In case we want to gain performance over power they should set it to 1.",
						default:'$MMCC',
						action:"generic /sys/devices/msm_sdcc.1/mmc_host/mmc0/clk_scaling/scale_down_in_low_wr_load"
					}},'
				fi`
			{ SPane:{
				title:"General I/O Tunables",
				description:"Set the internal storage general tunables"
			}},
				{ SCheckBox:{
					description:"Draw entropy from spinning (rotational) storage.",
					label:"Add Random",
					default:`$BB cat /sys/block/mmcblk0/queue/add_random`,
					action:"ioset queue add_random"
				}},
				{ SCheckBox:{
					description:"Maintain I/O statistics for this storage device. Disabling will break I/O monitoring apps.",
					label:"I/O Stats",
					default:`$BB cat /sys/block/mmcblk0/queue/iostats`,
					action:"ioset queue iostats"
				}},
				{ SCheckBox:{
					description:"Treat device as rotational storage.",
					label:"Rotational",
					default:`$BB cat /sys/block/mmcblk0/queue/rotational`,
					action:"ioset queue rotational"
				}},				
				{ SOptionList:{
					title:"No Merges",
					description:"Types of merges (prioritization) the scheduler queue for this storage device allows.",
					default:`$BB cat /sys/block/mmcblk0/queue/nomerges`,
					action:"ioset queue nomerges",
					values:{
						0:"All", 1:"Simple Only", 2:"None"
					}
				}},
				{ SOptionList:{
					title:"RQ Affinity",
					description:"Try to have scheduler requests complete on the CPU core they were made from. Higher is more aggressive. Some kernels only support 0-1.",
					default:`$BB cat /sys/block/mmcblk0/queue/rq_affinity`,
					action:"ioset queue rq_affinity",
					values:{
						0:"Disabled", 1:"Enabled", 2:"Aggressive"
					}
				}},
				{ SSeekBar:{
					title:"NR Requests",
					description:"Maximum number of read (or write) requests that can be queued to the scheduler in the block layer.",
					step:128,
					min:128,
					max:2048,
					default:`$BB cat /sys/block/mmcblk0/queue/nr_requests`,
					action:"ioset queue nr_requests"
				}},
			{ SPane:{
				title:"I/O Scheduler Tunables"
			}},
				{ STreeDescriptor:{
					path:"`sh $DEVICE DirIOSchedulerTree`",
					generic: {
						directory: {},
						element: {
							SGeneric: { title:"@BASENAME" }
						}
					},
					exclude: [ "weights" ]
				}},
	{ SPane:{
		title:"I/O schedulers",
		description:"Set the active I/O elevator algorithm. The scheduler decides how to handle I/O requests and how to handle them."
    }},
	{ SOptionList:{
		title:"Internal_storage scheduler",
		default:`cat /sys/block/mmcblk0/queue/scheduler | busybox awk 'NR>1{print $1}' RS=[ FS=]`,
		action:"scheduler /sys/block/mmcblk0/queue/scheduler",
		values:[`while read values; do busybox printf "%s, \n" $values | busybox tr -d '[]'; done < /sys/block/mmcblk0/queue/scheduler`]
	}},
	{ SSeekBar:{
		title:"Internal_storage read-ahead",
		max:2048,
		min:128,
		unit:" kB",
		step:128,
		default:`cat /sys/block/mmcblk0/queue/read_ahead_kb`,
		action:"generic /sys/block/mmcblk0/queue/read_ahead_kb"
	}},
	{ SOptionList:{
		title:"ExternalSD scheduler",
		default:`cat /sys/block/mmcblk1/queue/scheduler | busybox awk 'NR>1{print $1}' RS=[ FS=]`,
		action:"scheduler /sys/block/mmcblk1/queue/scheduler",
		values:[`while read values; do busybox printf "%s, \n" $values | busybox tr -d '[]'; done < /sys/block/mmcblk1/queue/scheduler`]
	}},
	{ SSeekBar:{
		title:"ExternalSD  read-ahead",
		max:2048,
		min:128,
		unit:" kB",
		step:128,
		default:`cat /sys/block/mmcblk1/queue/read_ahead_kb`,
		action:"generic /sys/block/mmcblk1/queue/read_ahead_kb"
	}},
	{ SPane:{
		title:"I/O Scheduler Tunables - Internal",
	}},
	{ STreeDescriptor:{
		path:"/sys/block/mmcblk0/queue/iosched",
		generic: {
			directory: {},
			element: {
				SGeneric: { title:"@BASENAME" }
			}
		},
		exclude: [ "weights" ]
	}},
	{ SPane:{
		title:"I/O Scheduler Tunables - External",
	}},
	{ STreeDescriptor:{
		path:"/sys/block/mmcblk1/queue/iosched",
		generic: {
			directory: {},
			element: {
				SGeneric: { title:"@BASENAME" }
			}
		},
		exclude: [ "weights" ]
	}},			
		]
}
CTAG
