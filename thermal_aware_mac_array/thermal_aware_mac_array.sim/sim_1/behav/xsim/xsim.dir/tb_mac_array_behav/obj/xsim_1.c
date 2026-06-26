/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2020 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/

#if defined(_WIN32)
 #include "stdio.h"
 #define IKI_DLLESPEC __declspec(dllimport)
#else
 #define IKI_DLLESPEC
#endif
#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2020 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/

#if defined(_WIN32)
 #include "stdio.h"
 #define IKI_DLLESPEC __declspec(dllimport)
#else
 #define IKI_DLLESPEC
#endif
#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
typedef void (*funcp)(char *, char *);
extern int main(int, char**);
IKI_DLLESPEC extern void execute_771(char*, char *);
IKI_DLLESPEC extern void execute_776(char*, char *);
IKI_DLLESPEC extern void execute_1038(char*, char *);
IKI_DLLESPEC extern void execute_1039(char*, char *);
IKI_DLLESPEC extern void execute_1040(char*, char *);
IKI_DLLESPEC extern void execute_1041(char*, char *);
IKI_DLLESPEC extern void execute_1042(char*, char *);
IKI_DLLESPEC extern void execute_4(char*, char *);
IKI_DLLESPEC extern void execute_5(char*, char *);
IKI_DLLESPEC extern void vlog_simple_process_execute_0_fast_for_reg(char*, char*, char*);
IKI_DLLESPEC extern void execute_778(char*, char *);
IKI_DLLESPEC extern void execute_779(char*, char *);
IKI_DLLESPEC extern void execute_780(char*, char *);
IKI_DLLESPEC extern void execute_781(char*, char *);
IKI_DLLESPEC extern void execute_1043(char*, char *);
IKI_DLLESPEC extern void execute_1044(char*, char *);
IKI_DLLESPEC extern void execute_1045(char*, char *);
IKI_DLLESPEC extern void execute_1046(char*, char *);
IKI_DLLESPEC extern void execute_1047(char*, char *);
IKI_DLLESPEC extern void execute_1048(char*, char *);
IKI_DLLESPEC extern void vlog_transfunc_eventcallback(char*, char*, unsigned, unsigned, unsigned, char *);
IKI_DLLESPEC extern void transaction_0(char*, char*, unsigned, unsigned, unsigned);
funcp funcTab[22] = {(funcp)execute_771, (funcp)execute_776, (funcp)execute_1038, (funcp)execute_1039, (funcp)execute_1040, (funcp)execute_1041, (funcp)execute_1042, (funcp)execute_4, (funcp)execute_5, (funcp)vlog_simple_process_execute_0_fast_for_reg, (funcp)execute_778, (funcp)execute_779, (funcp)execute_780, (funcp)execute_781, (funcp)execute_1043, (funcp)execute_1044, (funcp)execute_1045, (funcp)execute_1046, (funcp)execute_1047, (funcp)execute_1048, (funcp)vlog_transfunc_eventcallback, (funcp)transaction_0};
const int NumRelocateId= 22;

void relocate(char *dp)
{
	iki_relocate(dp, "xsim.dir/tb_mac_array_behav/xsim.reloc",  (void **)funcTab, 22);

	/*Populate the transaction function pointer field in the whole net structure */
}

void sensitize(char *dp)
{
	iki_sensitize(dp, "xsim.dir/tb_mac_array_behav/xsim.reloc");
}

void simulate(char *dp)
{
		iki_schedule_processes_at_time_zero(dp, "xsim.dir/tb_mac_array_behav/xsim.reloc");
	// Initialize Verilog nets in mixed simulation, for the cases when the value at time 0 should be propagated from the mixed language Vhdl net
	iki_execute_processes();

	// Schedule resolution functions for the multiply driven Verilog nets that have strength
	// Schedule transaction functions for the singly driven Verilog nets that have strength

}
#include "iki_bridge.h"
void relocate(char *);

void sensitize(char *);

void simulate(char *);

extern SYSTEMCLIB_IMP_DLLSPEC void local_register_implicit_channel(int, char*);
extern SYSTEMCLIB_IMP_DLLSPEC int xsim_argc_copy ;
extern SYSTEMCLIB_IMP_DLLSPEC char** xsim_argv_copy ;

int main(int argc, char **argv)
{
    iki_heap_initialize("ms", "isimmm", 0, 2147483648) ;
    iki_set_xsimdir_location_if_remapped(argc, argv)  ;
    iki_set_sv_type_file_path_name("xsim.dir/tb_mac_array_behav/xsim.svtype");
    iki_set_crvs_dump_file_path_name("xsim.dir/tb_mac_array_behav/xsim.crvsdump");
    void* design_handle = iki_create_design("xsim.dir/tb_mac_array_behav/xsim.mem", (void *)relocate, (void *)sensitize, (void *)simulate, (void*)0, 0, isimBridge_getWdbWriter(), 0, argc, argv);
     iki_set_rc_trial_count(100);
    (void) design_handle;
    return iki_simulate_design();
}
