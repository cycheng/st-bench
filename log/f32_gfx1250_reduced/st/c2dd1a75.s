
/******************************************/
/* Begin Kernel                           */
/******************************************/
.amdgcn_target "amdgcn-amd-amdhsa--gfx1250"
.text
.protected Cijk_Alik_Bljk_S_B_Bias_HA_S_SAV_UserArgs_MT32x32x32_MI16x16x1_SN_LDSB0_AFC1_AG0_AFEM1_AFEM1_ASEM1_CLR1_CADS0_DTLA0_DTLB0_DTVA0_DTVB0_DTVMXSA0_DTVMXSB0_DTVSM0_DPLB0_EPS0_ELFLR0_EMLLn1_FDSI0_GRPM1_GRVWA4_GRVWB4_GSUAMB_GLS0_ISA1250_IU1_K1_LDSTI0_LBSPPA256_LBSPPB256_LBSPPM0_LPA8_LPB8_LPM0_LRVWn1_LWPMn1_MIAV1_MIWT1_1_MO40_MGRIPM1_NTn1_NTA0_NTB0_NTC0_NTD0_NTM0_NEPBS0_NLCA1_NLCB1_ONLL1_PGR2_PLR1_PKA0_SGROB0_SIA3_SS0_SPO0_SRVW0_SSO0_SVW8_SK0_SKFTR0_SKXCCM0_SGRO0_TDMI0_TIN0_TLDS1_TLDSMn1_ULSGRO0_USL1_UIOFGRO0_UPLRP0_USFGROn1_VSn1_VWA1_VWB1_WSGRA0_WSGRB0_WS32_WG32_4_1
.globl Cijk_Alik_Bljk_S_B_Bias_HA_S_SAV_UserArgs_MT32x32x32_MI16x16x1_SN_LDSB0_AFC1_AG0_AFEM1_AFEM1_ASEM1_CLR1_CADS0_DTLA0_DTLB0_DTVA0_DTVB0_DTVMXSA0_DTVMXSB0_DTVSM0_DPLB0_EPS0_ELFLR0_EMLLn1_FDSI0_GRPM1_GRVWA4_GRVWB4_GSUAMB_GLS0_ISA1250_IU1_K1_LDSTI0_LBSPPA256_LBSPPB256_LBSPPM0_LPA8_LPB8_LPM0_LRVWn1_LWPMn1_MIAV1_MIWT1_1_MO40_MGRIPM1_NTn1_NTA0_NTB0_NTC0_NTD0_NTM0_NEPBS0_NLCA1_NLCB1_ONLL1_PGR2_PLR1_PKA0_SGROB0_SIA3_SS0_SPO0_SRVW0_SSO0_SVW8_SK0_SKFTR0_SKXCCM0_SGRO0_TDMI0_TIN0_TLDS1_TLDSMn1_ULSGRO0_USL1_UIOFGRO0_UPLRP0_USFGROn1_VSn1_VWA1_VWB1_WSGRA0_WSGRB0_WS32_WG32_4_1
.p2align 8
.type Cijk_Alik_Bljk_S_B_Bias_HA_S_SAV_UserArgs_MT32x32x32_MI16x16x1_SN_LDSB0_AFC1_AG0_AFEM1_AFEM1_ASEM1_CLR1_CADS0_DTLA0_DTLB0_DTVA0_DTVB0_DTVMXSA0_DTVMXSB0_DTVSM0_DPLB0_EPS0_ELFLR0_EMLLn1_FDSI0_GRPM1_GRVWA4_GRVWB4_GSUAMB_GLS0_ISA1250_IU1_K1_LDSTI0_LBSPPA256_LBSPPB256_LBSPPM0_LPA8_LPB8_LPM0_LRVWn1_LWPMn1_MIAV1_MIWT1_1_MO40_MGRIPM1_NTn1_NTA0_NTB0_NTC0_NTD0_NTM0_NEPBS0_NLCA1_NLCB1_ONLL1_PGR2_PLR1_PKA0_SGROB0_SIA3_SS0_SPO0_SRVW0_SSO0_SVW8_SK0_SKFTR0_SKXCCM0_SGRO0_TDMI0_TIN0_TLDS1_TLDSMn1_ULSGRO0_USL1_UIOFGRO0_UPLRP0_USFGROn1_VSn1_VWA1_VWB1_WSGRA0_WSGRB0_WS32_WG32_4_1,@function
.section .rodata,#alloc
.p2align 6
.amdhsa_kernel Cijk_Alik_Bljk_S_B_Bias_HA_S_SAV_UserArgs_MT32x32x32_MI16x16x1_SN_LDSB0_AFC1_AG0_AFEM1_AFEM1_ASEM1_CLR1_CADS0_DTLA0_DTLB0_DTVA0_DTVB0_DTVMXSA0_DTVMXSB0_DTVSM0_DPLB0_EPS0_ELFLR0_EMLLn1_FDSI0_GRPM1_GRVWA4_GRVWB4_GSUAMB_GLS0_ISA1250_IU1_K1_LDSTI0_LBSPPA256_LBSPPB256_LBSPPM0_LPA8_LPB8_LPM0_LRVWn1_LWPMn1_MIAV1_MIWT1_1_MO40_MGRIPM1_NTn1_NTA0_NTB0_NTC0_NTD0_NTM0_NEPBS0_NLCA1_NLCB1_ONLL1_PGR2_PLR1_PKA0_SGROB0_SIA3_SS0_SPO0_SRVW0_SSO0_SVW8_SK0_SKFTR0_SKXCCM0_SGRO0_TDMI0_TIN0_TLDS1_TLDSMn1_ULSGRO0_USL1_UIOFGRO0_UPLRP0_USFGROn1_VSn1_VWA1_VWB1_WSGRA0_WSGRB0_WS32_WG32_4_1
  .amdhsa_user_sgpr_kernarg_segment_ptr 1
  .amdhsa_next_free_vgpr 198 // vgprs
  .amdhsa_next_free_sgpr 72 // sgprs
  .amdhsa_group_segment_fixed_size 25600 // lds bytes
  .amdhsa_wavefront_size32 1 // 32-thread wavefronts
  .amdhsa_private_segment_fixed_size 0
  .amdhsa_system_sgpr_workgroup_id_x 1
  .amdhsa_system_sgpr_workgroup_id_y 1
  .amdhsa_system_sgpr_workgroup_id_z 1
  .amdhsa_system_vgpr_workitem_id 0
  .amdhsa_float_denorm_mode_32 3
  .amdhsa_float_denorm_mode_16_64 3
.end_amdhsa_kernel
.text
/* Num VGPR   =198 */
/* Num AccVGPR=0 */
/* Num SGPR   =72 */

/******************************************/
/* Optimizations and Config:              */
/******************************************/
/* ThreadTile= 8 x 1 */
/* SubGroup= 4 x 32 */
/* VectorWidthA=1 */
/* VectorWidthB=1 */
/* GlobalReadVectorWidthA=4, GlobalReadVectorWidthB=4 */
/* DirectToLdsA=False */
/* DirectToLdsB=False */
/* UseSgprForGRO=True */
.amdgpu_metadata
---
custom.config:
  InternalSupportParams:
    KernArgsVersion: 2
amdhsa.version:
  - 1
  - 1
amdhsa.kernels:
  - .name: Cijk_Alik_Bljk_S_B_Bias_HA_S_SAV_UserArgs_MT32x32x32_MI16x16x1_SN_LDSB0_AFC1_AG0_AFEM1_AFEM1_ASEM1_CLR1_CADS0_DTLA0_DTLB0_DTVA0_DTVB0_DTVMXSA0_DTVMXSB0_DTVSM0_DPLB0_EPS0_ELFLR0_EMLLn1_FDSI0_GRPM1_GRVWA4_GRVWB4_GSUAMB_GLS0_ISA1250_IU1_K1_LDSTI0_LBSPPA256_LBSPPB256_LBSPPM0_LPA8_LPB8_LPM0_LRVWn1_LWPMn1_MIAV1_MIWT1_1_MO40_MGRIPM1_NTn1_NTA0_NTB0_NTC0_NTD0_NTM0_NEPBS0_NLCA1_NLCB1_ONLL1_PGR2_PLR1_PKA0_SGROB0_SIA3_SS0_SPO0_SRVW0_SSO0_SVW8_SK0_SKFTR0_SKXCCM0_SGRO0_TDMI0_TIN0_TLDS1_TLDSMn1_ULSGRO0_USL1_UIOFGRO0_UPLRP0_USFGROn1_VSn1_VWA1_VWB1_WSGRA0_WSGRB0_WS32_WG32_4_1
    .symbol: 'Cijk_Alik_Bljk_S_B_Bias_HA_S_SAV_UserArgs_MT32x32x32_MI16x16x1_SN_LDSB0_AFC1_AG0_AFEM1_AFEM1_ASEM1_CLR1_CADS0_DTLA0_DTLB0_DTVA0_DTVB0_DTVMXSA0_DTVMXSB0_DTVSM0_DPLB0_EPS0_ELFLR0_EMLLn1_FDSI0_GRPM1_GRVWA4_GRVWB4_GSUAMB_GLS0_ISA1250_IU1_K1_LDSTI0_LBSPPA256_LBSPPB256_LBSPPM0_LPA8_LPB8_LPM0_LRVWn1_LWPMn1_MIAV1_MIWT1_1_MO40_MGRIPM1_NTn1_NTA0_NTB0_NTC0_NTD0_NTM0_NEPBS0_NLCA1_NLCB1_ONLL1_PGR2_PLR1_PKA0_SGROB0_SIA3_SS0_SPO0_SRVW0_SSO0_SVW8_SK0_SKFTR0_SKXCCM0_SGRO0_TDMI0_TIN0_TLDS1_TLDSMn1_ULSGRO0_USL1_UIOFGRO0_UPLRP0_USFGROn1_VSn1_VWA1_VWB1_WSGRA0_WSGRB0_WS32_WG32_4_1.kd'
    .language:                   OpenCL C
    .language_version:
      - 2
      - 0
    .args:
      - .name:            Gemm info
        .size:            4
        .offset:          0
        .value_kind:      by_value
        .value_type:      u32
      - .name:            kernel info0
        .size:            4
        .offset:          4
        .value_kind:      by_value
        .value_type:      u32
      - .name:            kernel info1
        .size:            4
        .offset:          8
        .value_kind:      by_value
        .value_type:      u32
      - .name:            numWG
        .size:            4
        .offset:          12
        .value_kind:      by_value
        .value_type:      u32
      - .name:            SizesFree0
        .size:            4
        .offset:          16
        .value_kind:      by_value
        .value_type:      u32
      - .name:            SizesFree1
        .size:            4
        .offset:          20
        .value_kind:      by_value
        .value_type:      u32
      - .name:            SizesFree2
        .size:            4
        .offset:          24
        .value_kind:      by_value
        .value_type:      u32
      - .name:            SizesSum0
        .size:            4
        .offset:          28
        .value_kind:      by_value
        .value_type:      u32
      - .name:            D
        .size:            8
        .offset:          32
        .value_kind:      global_buffer
        .value_type:      f32
        .address_space:   generic
      - .name:            C
        .size:            8
        .offset:          40
        .value_kind:      global_buffer
        .value_type:      f32
        .address_space:   generic
      - .name:            A
        .size:            8
        .offset:          48
        .value_kind:      global_buffer
        .value_type:      f32
        .address_space:   generic
      - .name:            B
        .size:            8
        .offset:          56
        .value_kind:      global_buffer
        .value_type:      f32
        .address_space:   generic
      - .name:            strideD0
        .size:            4
        .offset:          64
        .value_kind:      by_value
        .value_type:      u32
      - .name:            strideD1
        .size:            4
        .offset:          68
        .value_kind:      by_value
        .value_type:      u32
      - .name:            strideC0
        .size:            4
        .offset:          72
        .value_kind:      by_value
        .value_type:      u32
      - .name:            strideC1
        .size:            4
        .offset:          76
        .value_kind:      by_value
        .value_type:      u32
      - .name:            strideA0
        .size:            4
        .offset:          80
        .value_kind:      by_value
        .value_type:      u32
      - .name:            strideA1
        .size:            4
        .offset:          84
        .value_kind:      by_value
        .value_type:      u32
      - .name:            strideB0
        .size:            4
        .offset:          88
        .value_kind:      by_value
        .value_type:      u32
      - .name:            strideB1
        .size:            4
        .offset:          92
        .value_kind:      by_value
        .value_type:      u32
      - .name:            alpha
        .size:            4
        .offset:          96
        .value_kind:      by_value
        .value_type:      f32
      - .name:            beta
        .size:            4
        .offset:          100
        .value_kind:      by_value
        .value_type:      f32
      - .name:            AddressScaleAlphaVec
        .size:            8
        .offset:          104
        .value_kind:      global_buffer
        .value_type:      f32
        .address_space:   generic
      - .name:            bias
        .size:            8
        .offset:          112
        .value_kind:      global_buffer
        .value_type:      void
        .address_space:   generic
      - .name:            biasType
        .size:            4
        .offset:          120
        .value_kind:      by_value
        .value_type:      u32
      - .name:            StrideBias
        .size:            4
        .offset:          124
        .value_kind:      by_value
        .value_type:      u32
      - .name:            activationAlpha
        .size:            4
        .offset:          128
        .value_kind:      by_value
        .value_type:      f32
      - .name:            activationBeta
        .size:            4
        .offset:          132
        .value_kind:      by_value
        .value_type:      f32
      - .name:            activationType
        .size:            4
        .offset:          136
        .value_kind:      by_value
        .value_type:      u32
    .group_segment_fixed_size:   25600
    .kernarg_segment_align:      8
    .kernarg_segment_size:       144
    .max_flat_workgroup_size:    128
    .private_segment_fixed_size: 0
    .sgpr_count:                 72
    .sgpr_spill_count:           0
    .vgpr_count:                 198
    .vgpr_spill_count:           0
    .wavefront_size:             32
...
.end_amdgpu_metadata
Cijk_Alik_Bljk_S_B_Bias_HA_S_SAV_UserArgs_MT32x32x32_MI16x16x1_SN_LDSB0_AFC1_AG0_AFEM1_AFEM1_ASEM1_CLR1_CADS0_DTLA0_DTLB0_DTVA0_DTVB0_DTVMXSA0_DTVMXSB0_DTVSM0_DPLB0_EPS0_ELFLR0_EMLLn1_FDSI0_GRPM1_GRVWA4_GRVWB4_GSUAMB_GLS0_ISA1250_IU1_K1_LDSTI0_LBSPPA256_LBSPPB256_LBSPPM0_LPA8_LPB8_LPM0_LRVWn1_LWPMn1_MIAV1_MIWT1_1_MO40_MGRIPM1_NTn1_NTA0_NTB0_NTC0_NTD0_NTM0_NEPBS0_NLCA1_NLCB1_ONLL1_PGR2_PLR1_PKA0_SGROB0_SIA3_SS0_SPO0_SRVW0_SSO0_SVW8_SK0_SKFTR0_SKXCCM0_SGRO0_TDMI0_TIN0_TLDS1_TLDSMn1_ULSGRO0_USL1_UIOFGRO0_UPLRP0_USFGROn1_VSn1_VWA1_VWB1_WSGRA0_WSGRB0_WS32_WG32_4_1:
label_ASM_Start:  /// Main body of the asm kernel
.macro V_MAGIC_DIV vgprDstIdx:req, dividend:req, magicNumber:req, magicShift:req, magicA:req
    s_nop 0
    s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_mul_hi_u32 v[\vgprDstIdx+1], \dividend, \magicNumber
    v_mul_lo_u32 v[\vgprDstIdx+0], \dividend, \magicA
    v_add_nc_u32 v[\vgprDstIdx+0], v[\vgprDstIdx+0], v[\vgprDstIdx+1]
    v_lshrrev_b32 v[\vgprDstIdx+0], \magicShift, v[\vgprDstIdx+0]
.endm

/******************************************/
/* VGPR Assignments for MX                */
/******************************************/
.set vgprMXSBase, 0

/******************************************/
/* VGPR Macro Assignments for MX          */
/******************************************/

/******************************************/
/* VGPR Assignments                       */
/******************************************/
/* ValuC range: [0-8), serializedStore enabled */
.set vgprValuC, 0
/* ValuA/B   Xn=PLR buffer idx,  In=InnerUnroll idx */
.set vgprBase, 16
.set vgprLocalWriteAddrA, 10
.set vgprLocalWriteAddrB, 11
.set vgprGlobalReadOffsetA, 8
.set vgprGlobalReadOffsetB, 9
.set vgprLocalReadAddrA, 12
.set vgprLocalReadAddrB, 13
.set vgprSerial, 66

/******************************************/
/* VGPR Macro Assignments                 */
/******************************************/
.set vgprValuA_X0_I0_BASE, vgprBase+0
.set vgprValuB_X0_I0_BASE, vgprBase+18
.set vgprG2LA_BASE, vgprBase+34
.set vgprG2LB_BASE, vgprBase+42
.set vgprValuA_X0_I0, vgprValuA_X0_I0_BASE+0
.set vgprValuA_X1_I0, vgprValuA_X0_I0_BASE+2
.set vgprValuA_X2_I0, vgprValuA_X0_I0_BASE+4
.set vgprValuA_X3_I0, vgprValuA_X0_I0_BASE+6
.set vgprValuA_X4_I0, vgprValuA_X0_I0_BASE+8
.set vgprValuA_X5_I0, vgprValuA_X0_I0_BASE+10
.set vgprValuA_X6_I0, vgprValuA_X0_I0_BASE+12
.set vgprValuA_X7_I0, vgprValuA_X0_I0_BASE+14
.set vgprValuB_X0_I0, vgprValuB_X0_I0_BASE+0
.set vgprValuB_X1_I0, vgprValuB_X0_I0_BASE+2
.set vgprValuB_X2_I0, vgprValuB_X0_I0_BASE+4
.set vgprValuB_X3_I0, vgprValuB_X0_I0_BASE+6
.set vgprValuB_X4_I0, vgprValuB_X0_I0_BASE+8
.set vgprValuB_X5_I0, vgprValuB_X0_I0_BASE+10
.set vgprValuB_X6_I0, vgprValuB_X0_I0_BASE+12
.set vgprValuB_X7_I0, vgprValuB_X0_I0_BASE+14
.set vgprG2LA, vgprG2LA_BASE+0
.set vgprG2LB, vgprG2LB_BASE+0

/******************************************/
/* SGPR Assignments                       */
/******************************************/
.set sgprKernArgAddress, 0
.set sgprWorkGroup0, 2
.set sgprWorkGroup1, 3
.set sgprWorkGroup2, 4
.set sgprArgType, 5
.set sgprGSUSumIdx, 6
.set sgprGSULog2BpeC, 8
.set sgprGSULog2BpeD, 9
.set sgprStaggerU, 10
.set sgprWGM, 11
.set sgprLoopCounterL, 12
.set sgprOrigLoopCounter, 13
.set sgprSrdD, 16
.set sgprSrdC, 20
.set sgprNumWorkGroups0, 14
.set sgprNumWorkGroups1, 15
.set sgprSizesFree, 24
.set sgprSizesSum, 27
.set sgprAddressD, 28
.set sgprAddressC, 30
.set sgprAddressA, 32
.set sgprAddressB, 34
.set sgprStridesD, 36
.set sgprStridesC, 38
.set sgprStridesA, 40
.set sgprStridesB, 42
.set sgprAlpha, 44
.set sgprBeta, 45
.set sgprGSU, 46

/* Size Assignments */
.set sgprSizeI, sgprSizesFree+0
.set sgprSizeJ, sgprSizesFree+1
.set sgprSizeK, sgprSizesFree+2
.set sgprSizeL, sgprSizesSum+0

/* Stride Assignments */
.set constStrideD0I, 1
.set sgprStrideD1J, sgprStridesD+0
.set sgprStrideDK, sgprStridesD+1
.set constStrideC0I, 1
.set sgprStrideC1J, sgprStridesC+0
.set sgprStrideCK, sgprStridesC+1
.set constStrideAL, 1
.set sgprStrideA0I, sgprStridesA+0
.set sgprStrideAK, sgprStridesA+1
.set constStrideBL, 1
.set sgprStrideB1J, sgprStridesB+0
.set sgprStrideBK, sgprStridesB+1

.set MT0, 32
.set MT1, 32
.set DepthU, 32
/* Number of elements to shift-left SRD */
.set SrdShiftLeftA, 4
.set SrdShiftLeftB, 4
/* 2GB limit - set offsets to -1 to exceed this and clamp */
.set BufferLimit, 0xffffffff
.set BufferOOB, 0x80000000

/******************************************/
/* Bits 127:96 of SRD.                    */
/* hex: 0x0                               */
/* num_records_upper (6b): 0              */
/* reserved (6b): 0                       */
/* stride (14b): 0                        */
/* stride_scale (2b): 0                   */
/* swizzle_enable (1b): 0                 */
/* oob_select (1b): 0                     */
/* type (2b): 0                           */
/******************************************/
.set Srd127_96, 0x0

/* Global Offset A */
.macro GLOBAL_OFFSET_A vgprAddr:req, vgprOffsetL:req, vgprOffset0I:req, vgprTmp:req
    v_mul_lo_u32 v[\vgprTmp+0], s[sgprStrideA0I], v[\vgprOffset0I] // mul d1 lower
    v_add_co_u32 v[\vgprAddr+0], vcc_lo, v[\vgprOffsetL], v[\vgprTmp+0] // accumulate K lower
    v_add_nc_u32 v[\vgprAddr+0], 0x4, v[\vgprAddr+0]   // add prepad for pointer shift
.endm

/* Global Offset B */
.macro GLOBAL_OFFSET_B vgprAddr:req, vgprOffsetL:req, vgprOffset1J:req, vgprTmp:req
    v_mul_lo_u32 v[\vgprTmp+0], s[sgprStrideB1J], v[\vgprOffset1J] // mul d1 lower
    v_add_co_u32 v[\vgprAddr+0], vcc_lo, v[\vgprOffsetL], v[\vgprTmp+0] // accumulate K lower
    v_add_nc_u32 v[\vgprAddr+0], 0x4, v[\vgprAddr+0]   // add prepad for pointer shift
.endm

/******************************************/
/* Allocate Resources                     */
/******************************************/

/* Init workgroup id from ttmp */
s_mov_b32 s[sgprWorkGroup0], ttmp9
s_and_b32 s[sgprWorkGroup1], 0xffff, ttmp7
s_lshr_b32 s[sgprWorkGroup2], ttmp7, 0x10

/* Load num of Gemms */
s_load_b32 s20, s[sgprKernArgAddress:sgprKernArgAddress+1], 0

/* Load packed kernel args (StaggerU/GSU) */
s_load_b32 s22, s[sgprKernArgAddress:sgprKernArgAddress+1], 4

/* Load WGM data */
s_load_b32 s[sgprWGM], s[sgprKernArgAddress:sgprKernArgAddress+1], 8

/* Load num of WGs */
s_load_b32 s23, s[sgprKernArgAddress:sgprKernArgAddress+1], 12
s_wait_kmcnt 0                                     // load args
s_lshr_b32 s21, s20, 0x1e                          // Get arg type
s_and_b32 s20, 0x3fffffff, s20                     // Get nums of gemm
s_cmp_eq_u32 s21, 0                                // Is kernel args
s_cbranch_scc0 label_HBMArgs
s_add_u32 s[sgprKernArgAddress], s[sgprKernArgAddress], 0x10 // Shift common args
s_addc_u32 s[sgprKernArgAddress+1], s[sgprKernArgAddress+1], 0

/* Load Kernel Args */
s_load_b512 s[24:39], s[sgprKernArgAddress:sgprKernArgAddress+1], 0 // 0
s_load_b128 s[40:43], s[sgprKernArgAddress:sgprKernArgAddress+1], 64 // 64
s_load_b64 s[44:45], s[sgprKernArgAddress:sgprKernArgAddress+1], 80 // 80
s_branch label_LoadArgsEnd
label_HBMArgs:

/* Load address of kernel arguments */
s_load_b64 s[sgprKernArgAddress:sgprKernArgAddress+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 16
s_wait_kmcnt 0                                     // wait for args to load
label_LoadArgsEnd:
s_and_b32 s[sgprStaggerU], s22, 0xffff0000         // Restore StaggerU related vars
s_lshr_b32 s[sgprStaggerU], s[sgprStaggerU], 0x10
s_and_b32 s[sgprGSU], s22, 0xffff                  // Restore GSUConfig and GSU
s_mov_b32 s[sgprArgType], s21
s_mov_b32 m0, 0x6400                               // LDS clamp at 25600 bytes
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_mov_b32 v[vgprSerial], v0                        // thread serial id
s_mov_b32 vcc_hi, 0                                // Ensure hi bits are zero

/* remap workgroup to XCCs */
s_lshr_b32 s52, s[sgprWGM], 0x10                   // Get WGMXCC
s_ff1_i32_b32 s52, s52                             // Get log(WGMXCC)
s_lshr_b32 s53, s[sgprWGM], 0x16                   // Get CU_Count
/* remap WGs if WGMXCC > 1 ( log(WGMXCC) > 0 ) */
s_cmp_gt_i32 s52, 0
s_cbranch_scc0 label_skip_WGMXCC
/* only remap WGs in the range */
s_lshr_b32 s49, s23, s52
s_lshl_b32 s49, s49, s52
s_cmp_ge_u32 s[sgprWorkGroup0], s49
s_cbranch_scc1 label_skip_WGMXCC
s_cmp_eq_u32 s53, 0                                // CU_Count == 0 ?
s_cbranch_scc0 label_XCCG_nonzero
s_lshr_b32 s49, s[sgprWorkGroup0], s52
s_bfm_b32 s50, s52, 0
s_and_b32 s50, s[sgprWorkGroup0], s50
s_lshr_b32 s51, s23, s52
s_mul_i32 s50, s50, s51
s_add_u32 s[sgprWorkGroup0], s49, s50
s_branch label_skip_WGMXCC
label_XCCG_nonzero:
/* temp0 = (wg//CU_Count)*CU_Count */
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_cvt_f64_u32 v[16:17], s53                        // s49 = s[sgprWorkGroup0] / s53
v_rcp_f64 v[16:17], v[16:17]                       // s49 = s[sgprWorkGroup0] / s53
v_cvt_f64_u32 v[18:19], s[sgprWorkGroup0]          // s49 = s[sgprWorkGroup0] / s53
v_mul_f64 v[16:17], v[16:17], v[18:19]             // s49 = s[sgprWorkGroup0] / s53
v_cvt_u32_f64 v16, v[16:17]                        // s49 = s[sgprWorkGroup0] / s53
v_mul_lo_u32 v17, v16, s53                         // s49 = s[sgprWorkGroup0] / s53
v_sub_nc_u32 v18, s[sgprWorkGroup0], v17           // s49 = s[sgprWorkGroup0] / s53
v_cmp_ge_u32 vcc_lo, v18, s53                      // s49 = s[sgprWorkGroup0] / s53
s_mov_b32 exec_lo, vcc_lo                          // s49 = s[sgprWorkGroup0] / s53
v_add_nc_u32 v16, v16, 1                           // s49 = s[sgprWorkGroup0] / s53
s_mov_b32 exec_lo, -1                              // Reset exec
v_mul_lo_u32 v17, v16, s53                         // s49 = s[sgprWorkGroup0] / s53
v_sub_nc_u32 v18, s[sgprWorkGroup0], v17           // s49 = s[sgprWorkGroup0] / s53
v_readfirstlane_b32 s49, v16                       // quotient
v_readfirstlane_b32 s50, v18                       // remainder
s_mul_i32 s49, s49, s53
/* temp1 = (wg%CU_Count)//WGMXCC */
s_lshr_b32 s50, s50, s52
/* temp0 = temp0 + temp1 */
s_add_u32 s49, s49, s50
/* temp1 = (wg%WGMXCC) * ((WGs - (WGs//CU_Count) * CU_Count) if (wg > (WGs//CU_Count) * CU_Count) else CU_Count)//WGMXCC */
v_cvt_f64_u32 v[16:17], s53                        // s50 = s23 / s53
v_rcp_f64 v[16:17], v[16:17]                       // s50 = s23 / s53
v_cvt_f64_u32 v[18:19], s23                        // s50 = s23 / s53
v_mul_f64 v[16:17], v[16:17], v[18:19]             // s50 = s23 / s53
v_cvt_u32_f64 v16, v[16:17]                        // s50 = s23 / s53
v_mul_lo_u32 v17, v16, s53                         // s50 = s23 / s53
v_sub_nc_u32 v18, s23, v17                         // s50 = s23 / s53
v_cmp_ge_u32 vcc_lo, v18, s53                      // s50 = s23 / s53
s_mov_b32 exec_lo, vcc_lo                          // s50 = s23 / s53
v_add_nc_u32 v16, v16, 1                           // s50 = s23 / s53
s_mov_b32 exec_lo, -1                              // Reset exec
v_readfirstlane_b32 s50, v16                       // quotient
s_mul_i32 s50, s50, s53
s_sub_u32 s51, s23, s50
s_cmp_gt_u32 s[sgprWorkGroup0], s50
s_cselect_b32 s50, s51, s53
s_lshr_b32 s50, s50, s52
s_bfm_b32 s51, s52, 0
s_and_b32 s51, s[sgprWorkGroup0], s51
s_mul_i32 s50, s50, s51
/* WorkGroup0 = temp0 + temp1 */
s_add_u32 s[sgprWorkGroup0], s49, s50
label_skip_WGMXCC:  /// skip WGMXCC if no enough WGs to remap
s_cmp_eq_u32 s21, 0
s_cbranch_scc0 label_MultiGemm
/* init: add vgpr [16...66) to pool */
/* init: add vgpr [0...8) to pool */
/* init: add agpr [0...0) to pool */

/******************************************/
/* Local Read Addresses                   */
/******************************************/

/* local read addresses: tile assignments a/b */
/* lr0I */
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_and_b32 v1, 31, v[vgprSerial]                    // 0. thread id in wave: wtid = tid % wavelength(32)
v_and_b32 v0, 15, v1                               // 1. N offset: nIdx = wtid % MI_N(16)
v_lshlrev_b32 v0, 5, v0                            // 1. N offset: nOffset = nIdx * nStride(32)
/* Skip. 2. block offset: bnOffset = 0 when num1DBlocks = 1 */
                                                   // 4. apply VectorWidth: bnOffset = bnOffset * vw(1) (multiplier is 1, do nothing)
v_lshrrev_b32 v1, 4, v1                            // 5. K offset: kIdx = wtid / (MIN(16) * MIBB(1))
v_lshl_add_u32 v0, v1, 2, v0                       // 5. K offset: lrKOffset = kIdx * mStride(4); 6. offset in wave: lrOffset = bnOffset + lrKOffset
v_lshrrev_b32 v4, 5, v[vgprSerial]                 // 7. wave offset in N dimen: wtid = tid / dividedForWaveId(32)
v_and_b32 v4, 1, v4                                // 7. wave offset in M dimen: wtid0 = wtid / num1DWaves(2)
v_lshl_add_u32 v0, v4, 9, v0                       // 7. wave offset in M dimen: wOffset = wtid0 * W0Stride(512); 7. final local read offset: flrOffset = lrOffset + WOffset
/* lr1J */
v_and_b32 v2, 31, v[vgprSerial]                    // 0. thread id in wave: wtid = tid % wavelength(32)
v_and_b32 v1, 15, v2                               // 1. N offset: nIdx = wtid % MI_N(16)
v_lshlrev_b32 v1, 5, v1                            // 1. N offset: nOffset = nIdx * nStride(32)
/* Skip. 2. block offset: bnOffset = 0 when num1DBlocks = 1 */
                                                   // 4. apply VectorWidth: bnOffset = bnOffset * vw(1) (multiplier is 1, do nothing)
v_lshrrev_b32 v2, 4, v2                            // 5. K offset: kIdx = wtid / (MIN(16) * MIBB(1))
v_lshl_add_u32 v1, v2, 2, v1                       // 5. K offset: lrKOffset = kIdx * mStride(4); 6. offset in wave: lrOffset = bnOffset + lrKOffset
v_lshrrev_b32 v3, 6, v[vgprSerial]                 // 7. wave offset in N dimen: wtid = tid / dividedForWaveId(64)
v_and_b32 v3, 1, v3                                // 7. wave offset in M dimen: wtid0 = wtid / num1DWaves(2)
v_lshl_add_u32 v1, v3, 9, v1                       // 7. wave offset in M dimen: wOffset = wtid0 * W0Stride(512); 7. final local read offset: flrOffset = lrOffset + WOffset

/* local read addresses: final offsets a */
v_lshrrev_b32 v2, 5, v[vgprSerial]                 // 2 = Serial / 32
v_lshrrev_b32 v2, 2, v2                            // LSU offset: Get LSU wave_id
s_mov_b32 s16, 32                                  // LSU offset: stride = lsuStride(32) when umlds==True
v_mul_lo_u32 v2, s16, v2                           // LSU offset: lsuoffset = wave_id*lsuStride*(MT0+PAD)
v_add_nc_u32 v[vgprLocalReadAddrA], v2, v0         // Final Offset: offset = (lro0+lsuoffset)*bpeDS
v_lshlrev_b32 v[vgprLocalReadAddrA], 2, v[vgprLocalReadAddrA] //  (multiple bpe)
v_lshrrev_b32 v3, 8, v[vgprLocalReadAddrA]         // Final Offset: padding 32 per block 256
v_lshl_add_u32 v[vgprLocalReadAddrA], v3, 5, v[vgprLocalReadAddrA] // Final Offset: padding 32 per block 256

/* local read addresses: final offsets b */
v_lshrrev_b32 v0, 5, v[vgprSerial]                 // 0 = Serial / 32
v_lshrrev_b32 v0, 2, v0                            // LSU offset: Get LSU wave_id
                                                   // LSU offset: stride = lsuStride(32) when umlds==True (dup assign opt.)
v_mul_lo_u32 v0, s16, v0                           // LSU offset: lsuoffset = wave_id*lsuStride*(MT1+PAD)
v_add_nc_u32 v[vgprLocalReadAddrB], v0, v1         // Final Offset: offset = (lro1+lsuoffset)*bpeDS
v_lshlrev_b32 v[vgprLocalReadAddrB], 2, v[vgprLocalReadAddrB] //  (multiple bpe)
v_lshrrev_b32 v2, 8, v[vgprLocalReadAddrB]         // Final Offset: padding 32 per block 256
v_lshl_add_u32 v[vgprLocalReadAddrB], v2, 5, v[vgprLocalReadAddrB] // Final Offset: padding 32 per block 256

/* local read addresses: declare addresses a */

/* local read addresses: declare addresses b */
v_add_co_u32 v[vgprLocalReadAddrB+0], vcc_lo, 0x1200, v[vgprLocalReadAddrB+0] //  += LdsOffsetB (lower)

/******************************************/
/* Local Write Addresses                  */
/******************************************/
/* LVCA = 8 */
/* v1 = A-unroll = serial%LVCA */
v_lshrrev_b32 v0, 3, v[vgprSerial]                 // 0 = Serial / 8
v_and_b32 v1, 7, v[vgprSerial]                     // 1 = Serial % 8
/* unroll *= glvw */
v_lshlrev_b32 v1, 2, v1                            // v1 = v1 * 4
v_mov_b32 v4, v1                                   // copy for GlobalSplitU
/* LVCB = 8 */
/* v3 = B-unroll = serial%LVCB */
v_lshrrev_b32 v2, 3, v[vgprSerial]                 // 2 = Serial / 8
v_and_b32 v3, 7, v[vgprSerial]                     // 3 = Serial % 8
/* unroll *= glvw */
v_lshlrev_b32 v3, 2, v3                            // v3 = v3 * 4
v_mov_b32 v5, v3                                   // copy for GlobalSplitU
/* lwaUnrollAssignmentA = v4 */
/* lwaUnrollAssignmentB = v5 */

/* local write addresses: first offset a */
v_mul_u32_u24 v[vgprLocalWriteAddrA], 0x20, v0     // lwAL**(DepthU_Compute + PAD)
v_add_nc_u32 v[vgprLocalWriteAddrA], v4, v[vgprLocalWriteAddrA] // lwFOA = (lwAA + lwAL*(DepthU+PAD))
v_lshlrev_b32 v[vgprLocalWriteAddrA], 2, v[vgprLocalWriteAddrA] //  (multiple bpe)
v_lshrrev_b32 v6, 8, v[vgprLocalWriteAddrA]        // padding 32 per block 256
v_lshl_add_u32 v[vgprLocalWriteAddrA], v6, 5, v[vgprLocalWriteAddrA] // padding 32 per block 256

/* local write addresses: first offset b */
v_mul_u32_u24 v[vgprLocalWriteAddrB], 0x20, v2     // lwBL**(DepthU_Compute + PAD)
v_add_nc_u32 v[vgprLocalWriteAddrB], v5, v[vgprLocalWriteAddrB] // lwFOB = (lwBB + lwBL*(DepthU+PAD))
v_lshlrev_b32 v[vgprLocalWriteAddrB], 2, v[vgprLocalWriteAddrB] //  (multiple bpe)
v_lshrrev_b32 v6, 8, v[vgprLocalWriteAddrB]        // padding 32 per block 256
v_lshl_add_u32 v[vgprLocalWriteAddrB], v6, 5, v[vgprLocalWriteAddrB] // padding 32 per block 256
v_add_co_u32 v[vgprLocalWriteAddrB], vcc_lo, 0x1200, v[vgprLocalWriteAddrB] // lwFOB = lw1J + lwL*MT1J + LDS_OFFSET_B=4608
s_wait_kmcnt 0                                     // wait for 88/0 bytes of kern args
v_mov_b32 v18, MT0                                 // set MT0 into sgpr
v_mov_b32 v17, s[sgprSizesFree+0]                  // set Free0 size
v_cvt_f32_u32 v16, v18                             // v16 = ceil(v17 / v18)
v_rcp_iflag_f32 v16, v16                           // v16 = ceil(v17 / v18)
v_cvt_f32_u32 v19, v17                             // v16 = ceil(v17 / v18)
v_mul_f32 v16, v16, v19                            // v16 = ceil(v17 / v18)
v_cvt_u32_f32 v16, v16                             // v16 = ceil(v17 / v18)
v_mul_u32_u24 v19, v16, v18                        // v16 = ceil(v17 / v18)
v_sub_nc_u32 v19, v17, v19                         // v16 = ceil(v17 / v18)
v_cmp_ne_u32 vcc_lo, v19, 0                        // v16 = ceil(v17 / v18)
v_add_co_ci_u32 v16, vcc_lo, v16, 0, vcc_lo        // ceil
v_mov_b32 v18, MT1                                 // set MT1 into sgpr
v_mov_b32 v17, s[sgprSizesFree+1]                  // set Free1 size
v_readfirstlane_b32 s[sgprNumWorkGroups0], v16     // set back to numWorkGroup0
v_cvt_f32_u32 v16, v18                             // v16 = ceil(v17 / v18)
v_rcp_iflag_f32 v16, v16                           // v16 = ceil(v17 / v18)
v_cvt_f32_u32 v19, v17                             // v16 = ceil(v17 / v18)
v_mul_f32 v16, v16, v19                            // v16 = ceil(v17 / v18)
v_cvt_u32_f32 v16, v16                             // v16 = ceil(v17 / v18)
v_mul_u32_u24 v19, v16, v18                        // v16 = ceil(v17 / v18)
v_sub_nc_u32 v19, v17, v19                         // v16 = ceil(v17 / v18)
v_cmp_ne_u32 vcc_lo, v19, 0                        // v16 = ceil(v17 / v18)
v_add_co_ci_u32 v16, vcc_lo, v16, 0, vcc_lo        // ceil
v_readfirstlane_b32 s[sgprNumWorkGroups1], v16     // set back to numWorkGroup1

/* remap wg from 1D(idxWG012) to 3D(wg2,wg1,wg0) */
/* wg2 = idxWG012 * smallMagicNumber(1/(numWG0*numWG1)) */
s_mul_i32 s16, s[sgprNumWorkGroups0], s[sgprNumWorkGroups1]
s_and_b32 s17, s[sgprGSU], 0x3fff                  // Restore GSU
s_mul_i32 s16, s16, s17
v_cvt_f32_u32 v6, s16                              // s16 = s[sgprWorkGroup0] / s16
v_rcp_iflag_f32 v6, v6                             // s16 = s[sgprWorkGroup0] / s16
v_cvt_f32_u32 v7, s[sgprWorkGroup0]                // s16 = s[sgprWorkGroup0] / s16
v_mul_f32 v6, v6, v7                               // s16 = s[sgprWorkGroup0] / s16
v_cvt_u32_f32 v6, v6                               // s16 = s[sgprWorkGroup0] / s16
v_mul_u32_u24 v7, v6, s16                          // s16 = s[sgprWorkGroup0] / s16
v_sub_nc_u32 v7, s[sgprWorkGroup0], v7             // s16 = s[sgprWorkGroup0] / s16
v_cmp_eq_u32 vcc_lo, v7, s16                       // s16 = s[sgprWorkGroup0] / s16
s_mov_b32 exec_lo, vcc_lo                          // s16 = s[sgprWorkGroup0] / s16
v_add_nc_u32 v6, 1, v6                             // s16 = s[sgprWorkGroup0] / s16
s_mov_b32 exec_lo, -1                              // Reset exec
v_cmp_gt_u32 vcc_lo, v7, s16                       // overflow happened in remainder
s_mov_b32 exec_lo, vcc_lo                          // overflow happened in remainder
v_sub_nc_u32 v6, v6, 1                             // quotient - 1
s_mov_b32 exec_lo, -1                              // Reset exec
v_readfirstlane_b32 s16, v6                        // quotient
s_mov_b32 s[sgprWorkGroup2], s16
/* idxWG01 = idxWG012 - wg2 * numWG0 * numWG1 */
s_mul_i32 s16, s[sgprNumWorkGroups1], s[sgprNumWorkGroups0]
s_mul_i32 s16, s16, s[sgprWorkGroup2]
s_mul_i32 s16, s16, s17
s_sub_u32 s[sgprWorkGroup0], s[sgprWorkGroup0], s16
/* wg1 = idxWG01 * smallMagicNumber(1/numWG0) */
v_cvt_f32_u32 v6, s[sgprNumWorkGroups0]            // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
v_rcp_iflag_f32 v6, v6                             // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
v_cvt_f32_u32 v7, s[sgprWorkGroup0]                // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
v_mul_f32 v6, v6, v7                               // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
v_cvt_u32_f32 v6, v6                               // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
v_mul_u32_u24 v7, v6, s[sgprNumWorkGroups0]        // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
v_sub_nc_u32 v7, s[sgprWorkGroup0], v7             // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
v_cmp_eq_u32 vcc_lo, v7, s[sgprNumWorkGroups0]     // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
s_mov_b32 exec_lo, vcc_lo                          // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
v_add_nc_u32 v6, 1, v6                             // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
s_mov_b32 exec_lo, -1                              // Reset exec
v_cmp_gt_u32 vcc_lo, v7, s[sgprNumWorkGroups0]     // overflow happened in remainder
s_mov_b32 exec_lo, vcc_lo                          // overflow happened in remainder
v_sub_nc_u32 v6, v6, 1                             // quotient - 1
s_mov_b32 exec_lo, -1                              // Reset exec
v_readfirstlane_b32 s16, v6                        // quotient
s_mov_b32 s[sgprWorkGroup1], s16
/* wg0 = idxWG01 - wg1 * numWG0 */
s_mul_i32 s16, s[sgprWorkGroup1], s[sgprNumWorkGroups0]
s_sub_u32 s[sgprWorkGroup0], s[sgprWorkGroup0], s16
s_branch label_MultiGemmEnd
label_MultiGemm:

/* Check if custom structure pointer is null */
s_cmp_eq_u32 s[sgprArgType], 2                     // ArgType == 2 ?
s_cbranch_scc1 label_IsExternalValid               // branch if ArgType == 2
s_mov_b32 s15, 124
s_mul_i32 s54, s20, 4
s_mov_b64 s[48:49], s[sgprKernArgAddress:sgprKernArgAddress+1]
s_branch label_IsExternalValidEnd
label_IsExternalValid:
s_mov_b32 s15, 196
s_mov_b32 s54, 0
s_mov_b64 s[48:49], s[sgprKernArgAddress:sgprKernArgAddress+1]
label_IsExternalValidEnd:

/* Grouped Gemm:: prefetch 1 arg load */
s_mov_b32 s14, 1
s_mov_b32 s55, 0
s_load_b128 s[24:27], s[48:49], s54
s_mov_b32 s16, 1
s_cmp_eq_u32 s20, s16                              // if gemm_count is 1?
s_cbranch_scc1 label_wgTable_noLoadLoop

/* Grouped Gemm:: accumulate numTiles for each gemm */
/* Grouped Gemm:: loop start */
label_Loop_GemmCount:
s_wait_kmcnt 0
s_lshr_b32 s52, s24, 5                             // s52 = s24 / 32
s_and_b32 s50, 31, s24                             // s50 = s24 % 32
s_addc_u32 s52, s52, 0
s_lshr_b32 s53, s25, 5                             // s53 = s25 / 32
s_and_b32 s50, 31, s25                             // s50 = s25 % 32
s_addc_u32 s53, s53, 0
s_mul_i32 s52, s52, s53
s_mul_i32 s52, s52, s26
s_and_b32 s53, s[sgprGSU], 0x3fff                  // Restore GSU
s_mul_i32 s52, s52, s53
s_add_u32 s55, s55, s52
s_cmp_lt_u32 s[sgprWorkGroup0], s55
s_cbranch_scc1 label_FOUND
s_add_u32 s54, s54, s15
s_load_b128 s[24:27], s[48:49], s54
s_add_u32 s14, s14, 1
s_cmp_lt_u32 s14, s20
s_cbranch_scc1 label_Loop_GemmCount

/* Grouped Gemm:: noLoadLoop */
label_wgTable_noLoadLoop:
s_wait_kmcnt 0
s_lshr_b32 s52, s24, 5                             // s52 = s24 / 32
s_and_b32 s50, 31, s24                             // s50 = s24 % 32
s_addc_u32 s52, s52, 0
s_lshr_b32 s53, s25, 5                             // s53 = s25 / 32
s_and_b32 s50, 31, s25                             // s50 = s25 % 32
s_addc_u32 s53, s53, 0
s_mul_i32 s52, s52, s53
s_mul_i32 s52, s52, s26
s_and_b32 s48, s[sgprGSU], 0x3fff                  // Restore GSU
s_mul_i32 s52, s52, s48
s_add_u32 s55, s55, s52

/* Grouped Gemm:: gemmIndex found */
label_FOUND:
s_sub_u32 s49, s14, 1
s_sub_u32 s48, s55, s52
s_sub_u32 s[sgprWorkGroup0], s[sgprWorkGroup0], s48
/* Check if custom structure pointer is null */
s_cmp_eq_u32 s[sgprArgType], 2                     // ArgType == 2 ?
s_cbranch_scc1 label_LoadExternalStruct            // branch if ArgType == 2

/* Grouped Gemm: offset argument address to gemm */
/* Grouped Gemm: offset address from wg_table_start to args_start */
s_lshl2_add_u32 s[sgprKernArgAddress], s20, s[sgprKernArgAddress]
s_addc_u32 s[sgprKernArgAddress+1], s[sgprKernArgAddress+1], 0
/* Grouped Gemm: offset address from args_start to gemm_start */
s_mul_i32 s49, s49, 124
s_add_u32 s[sgprKernArgAddress], s[sgprKernArgAddress], s49
s_addc_u32 s[sgprKernArgAddress+1], s[sgprKernArgAddress+1], 0

/* Load Kernel Args */
s_load_b512 s[28:43], s[sgprKernArgAddress:sgprKernArgAddress+1], 16 // 16
s_load_b64 s[44:45], s[sgprKernArgAddress:sgprKernArgAddress+1], 80 // 80
s_branch label_LoadExternalStructEnd
label_LoadExternalStruct:
/* Grouped Gemm: offset address from args_start to gemm_start */
s_mul_i32 s49, s49, 196
s_add_u32 s[sgprKernArgAddress], s[sgprKernArgAddress], s49
s_addc_u32 s[sgprKernArgAddress+1], s[sgprKernArgAddress+1], 0
s_load_b512 s[28:43], s[sgprKernArgAddress:sgprKernArgAddress+1], 16 // 16
s_load_b32 s44, s[sgprKernArgAddress:sgprKernArgAddress+1], 80 // 80
// Read Beta
s_load_b32 s45, s[sgprKernArgAddress:sgprKernArgAddress+1], 96 // 96
label_LoadExternalStructEnd:
/* init: add vgpr [16...66) to pool */
/* init: add vgpr [0...8) to pool */
/* init: add agpr [0...0) to pool */

/******************************************/
/* Local Read Addresses                   */
/******************************************/

/* local read addresses: tile assignments a/b */
/* lr0I */
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_and_b32 v1, 31, v[vgprSerial]                    // 0. thread id in wave: wtid = tid % wavelength(32)
v_and_b32 v0, 15, v1                               // 1. N offset: nIdx = wtid % MI_N(16)
v_lshlrev_b32 v0, 5, v0                            // 1. N offset: nOffset = nIdx * nStride(32)
/* Skip. 2. block offset: bnOffset = 0 when num1DBlocks = 1 */
                                                   // 4. apply VectorWidth: bnOffset = bnOffset * vw(1) (multiplier is 1, do nothing)
v_lshrrev_b32 v1, 4, v1                            // 5. K offset: kIdx = wtid / (MIN(16) * MIBB(1))
v_lshl_add_u32 v0, v1, 2, v0                       // 5. K offset: lrKOffset = kIdx * mStride(4); 6. offset in wave: lrOffset = bnOffset + lrKOffset
v_lshrrev_b32 v4, 5, v[vgprSerial]                 // 7. wave offset in N dimen: wtid = tid / dividedForWaveId(32)
v_and_b32 v4, 1, v4                                // 7. wave offset in M dimen: wtid0 = wtid / num1DWaves(2)
v_lshl_add_u32 v0, v4, 9, v0                       // 7. wave offset in M dimen: wOffset = wtid0 * W0Stride(512); 7. final local read offset: flrOffset = lrOffset + WOffset
/* lr1J */
v_and_b32 v2, 31, v[vgprSerial]                    // 0. thread id in wave: wtid = tid % wavelength(32)
v_and_b32 v1, 15, v2                               // 1. N offset: nIdx = wtid % MI_N(16)
v_lshlrev_b32 v1, 5, v1                            // 1. N offset: nOffset = nIdx * nStride(32)
/* Skip. 2. block offset: bnOffset = 0 when num1DBlocks = 1 */
                                                   // 4. apply VectorWidth: bnOffset = bnOffset * vw(1) (multiplier is 1, do nothing)
v_lshrrev_b32 v2, 4, v2                            // 5. K offset: kIdx = wtid / (MIN(16) * MIBB(1))
v_lshl_add_u32 v1, v2, 2, v1                       // 5. K offset: lrKOffset = kIdx * mStride(4); 6. offset in wave: lrOffset = bnOffset + lrKOffset
v_lshrrev_b32 v3, 6, v[vgprSerial]                 // 7. wave offset in N dimen: wtid = tid / dividedForWaveId(64)
v_and_b32 v3, 1, v3                                // 7. wave offset in M dimen: wtid0 = wtid / num1DWaves(2)
v_lshl_add_u32 v1, v3, 9, v1                       // 7. wave offset in M dimen: wOffset = wtid0 * W0Stride(512); 7. final local read offset: flrOffset = lrOffset + WOffset

/* local read addresses: final offsets a */
v_lshrrev_b32 v2, 5, v[vgprSerial]                 // 2 = Serial / 32
v_lshrrev_b32 v2, 2, v2                            // LSU offset: Get LSU wave_id
s_mov_b32 s16, 32                                  // LSU offset: stride = lsuStride(32) when umlds==True
v_mul_lo_u32 v2, s16, v2                           // LSU offset: lsuoffset = wave_id*lsuStride*(MT0+PAD)
v_add_nc_u32 v[vgprLocalReadAddrA], v2, v0         // Final Offset: offset = (lro0+lsuoffset)*bpeDS
v_lshlrev_b32 v[vgprLocalReadAddrA], 2, v[vgprLocalReadAddrA] //  (multiple bpe)
v_lshrrev_b32 v3, 8, v[vgprLocalReadAddrA]         // Final Offset: padding 32 per block 256
v_lshl_add_u32 v[vgprLocalReadAddrA], v3, 5, v[vgprLocalReadAddrA] // Final Offset: padding 32 per block 256

/* local read addresses: final offsets b */
v_lshrrev_b32 v0, 5, v[vgprSerial]                 // 0 = Serial / 32
v_lshrrev_b32 v0, 2, v0                            // LSU offset: Get LSU wave_id
                                                   // LSU offset: stride = lsuStride(32) when umlds==True (dup assign opt.)
v_mul_lo_u32 v0, s16, v0                           // LSU offset: lsuoffset = wave_id*lsuStride*(MT1+PAD)
v_add_nc_u32 v[vgprLocalReadAddrB], v0, v1         // Final Offset: offset = (lro1+lsuoffset)*bpeDS
v_lshlrev_b32 v[vgprLocalReadAddrB], 2, v[vgprLocalReadAddrB] //  (multiple bpe)
v_lshrrev_b32 v2, 8, v[vgprLocalReadAddrB]         // Final Offset: padding 32 per block 256
v_lshl_add_u32 v[vgprLocalReadAddrB], v2, 5, v[vgprLocalReadAddrB] // Final Offset: padding 32 per block 256

/* local read addresses: declare addresses a */

/* local read addresses: declare addresses b */
v_add_co_u32 v[vgprLocalReadAddrB+0], vcc_lo, 0x1200, v[vgprLocalReadAddrB+0] //  += LdsOffsetB (lower)

/******************************************/
/* Local Write Addresses                  */
/******************************************/
/* LVCA = 8 */
/* v1 = A-unroll = serial%LVCA */
v_lshrrev_b32 v0, 3, v[vgprSerial]                 // 0 = Serial / 8
v_and_b32 v1, 7, v[vgprSerial]                     // 1 = Serial % 8
/* unroll *= glvw */
v_lshlrev_b32 v1, 2, v1                            // v1 = v1 * 4
v_mov_b32 v4, v1                                   // copy for GlobalSplitU
/* LVCB = 8 */
/* v3 = B-unroll = serial%LVCB */
v_lshrrev_b32 v2, 3, v[vgprSerial]                 // 2 = Serial / 8
v_and_b32 v3, 7, v[vgprSerial]                     // 3 = Serial % 8
/* unroll *= glvw */
v_lshlrev_b32 v3, 2, v3                            // v3 = v3 * 4
v_mov_b32 v5, v3                                   // copy for GlobalSplitU
/* lwaUnrollAssignmentA = v4 */
/* lwaUnrollAssignmentB = v5 */

/* local write addresses: first offset a */
v_mul_u32_u24 v[vgprLocalWriteAddrA], 0x20, v0     // lwAL**(DepthU_Compute + PAD)
v_add_nc_u32 v[vgprLocalWriteAddrA], v4, v[vgprLocalWriteAddrA] // lwFOA = (lwAA + lwAL*(DepthU+PAD))
v_lshlrev_b32 v[vgprLocalWriteAddrA], 2, v[vgprLocalWriteAddrA] //  (multiple bpe)
v_lshrrev_b32 v6, 8, v[vgprLocalWriteAddrA]        // padding 32 per block 256
v_lshl_add_u32 v[vgprLocalWriteAddrA], v6, 5, v[vgprLocalWriteAddrA] // padding 32 per block 256

/* local write addresses: first offset b */
v_mul_u32_u24 v[vgprLocalWriteAddrB], 0x20, v2     // lwBL**(DepthU_Compute + PAD)
v_add_nc_u32 v[vgprLocalWriteAddrB], v5, v[vgprLocalWriteAddrB] // lwFOB = (lwBB + lwBL*(DepthU+PAD))
v_lshlrev_b32 v[vgprLocalWriteAddrB], 2, v[vgprLocalWriteAddrB] //  (multiple bpe)
v_lshrrev_b32 v6, 8, v[vgprLocalWriteAddrB]        // padding 32 per block 256
v_lshl_add_u32 v[vgprLocalWriteAddrB], v6, 5, v[vgprLocalWriteAddrB] // padding 32 per block 256
v_add_co_u32 v[vgprLocalWriteAddrB], vcc_lo, 0x1200, v[vgprLocalWriteAddrB] // lwFOB = lw1J + lwL*MT1J + LDS_OFFSET_B=4608
s_wait_kmcnt 0                                     // wait for 88/0 bytes of kern args
v_mov_b32 v18, MT0                                 // set MT0 into sgpr
v_mov_b32 v17, s[sgprSizesFree+0]                  // set Free0 size
v_cvt_f32_u32 v16, v18                             // v16 = ceil(v17 / v18)
v_rcp_iflag_f32 v16, v16                           // v16 = ceil(v17 / v18)
v_cvt_f32_u32 v19, v17                             // v16 = ceil(v17 / v18)
v_mul_f32 v16, v16, v19                            // v16 = ceil(v17 / v18)
v_cvt_u32_f32 v16, v16                             // v16 = ceil(v17 / v18)
v_mul_u32_u24 v19, v16, v18                        // v16 = ceil(v17 / v18)
v_sub_nc_u32 v19, v17, v19                         // v16 = ceil(v17 / v18)
v_cmp_ne_u32 vcc_lo, v19, 0                        // v16 = ceil(v17 / v18)
v_add_co_ci_u32 v16, vcc_lo, v16, 0, vcc_lo        // ceil
v_mov_b32 v18, MT1                                 // set MT1 into sgpr
v_mov_b32 v17, s[sgprSizesFree+1]                  // set Free1 size
v_readfirstlane_b32 s[sgprNumWorkGroups0], v16     // set back to numWorkGroup0
v_cvt_f32_u32 v16, v18                             // v16 = ceil(v17 / v18)
v_rcp_iflag_f32 v16, v16                           // v16 = ceil(v17 / v18)
v_cvt_f32_u32 v19, v17                             // v16 = ceil(v17 / v18)
v_mul_f32 v16, v16, v19                            // v16 = ceil(v17 / v18)
v_cvt_u32_f32 v16, v16                             // v16 = ceil(v17 / v18)
v_mul_u32_u24 v19, v16, v18                        // v16 = ceil(v17 / v18)
v_sub_nc_u32 v19, v17, v19                         // v16 = ceil(v17 / v18)
v_cmp_ne_u32 vcc_lo, v19, 0                        // v16 = ceil(v17 / v18)
v_add_co_ci_u32 v16, vcc_lo, v16, 0, vcc_lo        // ceil
v_readfirstlane_b32 s[sgprNumWorkGroups1], v16     // set back to numWorkGroup1

/* Early stop if N(SizeFreeJ) == 0 */
s_cmp_eq_u32 s[sgprSizeJ], 0
s_cbranch_scc0 label_NoEarlyStop_N0
label_EarlyStop_if_N_is_0:
s_endpgm
label_NoEarlyStop_N0:

/* remap wg from 1D(idxWG012) to 3D(wg2,wg1,wg0) */
/* wg2 = idxWG012 * smallMagicNumber(1/(numWG0*numWG1)) */
s_mul_i32 s16, s[sgprNumWorkGroups0], s[sgprNumWorkGroups1]
s_and_b32 s17, s[sgprGSU], 0x3fff                  // Restore GSU
s_mul_i32 s16, s16, s17
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_cvt_f32_u32 v6, s16                              // s16 = s[sgprWorkGroup0] / s16
v_rcp_iflag_f32 v6, v6                             // s16 = s[sgprWorkGroup0] / s16
v_cvt_f32_u32 v7, s[sgprWorkGroup0]                // s16 = s[sgprWorkGroup0] / s16
v_mul_f32 v6, v6, v7                               // s16 = s[sgprWorkGroup0] / s16
v_cvt_u32_f32 v6, v6                               // s16 = s[sgprWorkGroup0] / s16
v_mul_u32_u24 v7, v6, s16                          // s16 = s[sgprWorkGroup0] / s16
v_sub_nc_u32 v7, s[sgprWorkGroup0], v7             // s16 = s[sgprWorkGroup0] / s16
v_cmp_eq_u32 vcc_lo, v7, s16                       // s16 = s[sgprWorkGroup0] / s16
s_mov_b32 exec_lo, vcc_lo                          // s16 = s[sgprWorkGroup0] / s16
v_add_nc_u32 v6, 1, v6                             // s16 = s[sgprWorkGroup0] / s16
s_mov_b32 exec_lo, -1                              // Reset exec
v_cmp_gt_u32 vcc_lo, v7, s16                       // overflow happened in remainder
s_mov_b32 exec_lo, vcc_lo                          // overflow happened in remainder
v_sub_nc_u32 v6, v6, 1                             // quotient - 1
s_mov_b32 exec_lo, -1                              // Reset exec
v_readfirstlane_b32 s16, v6                        // quotient
s_mov_b32 s[sgprWorkGroup2], s16
/* idxWG01 = idxWG012 - wg2 * numWG0 * numWG1 */
s_mul_i32 s16, s[sgprNumWorkGroups1], s[sgprNumWorkGroups0]
s_mul_i32 s16, s16, s[sgprWorkGroup2]
s_mul_i32 s16, s16, s17
s_sub_u32 s[sgprWorkGroup0], s[sgprWorkGroup0], s16
/* wg1 = idxWG01 * smallMagicNumber(1/numWG0) */
v_cvt_f32_u32 v6, s[sgprNumWorkGroups0]            // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
v_rcp_iflag_f32 v6, v6                             // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
v_cvt_f32_u32 v7, s[sgprWorkGroup0]                // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
v_mul_f32 v6, v6, v7                               // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
v_cvt_u32_f32 v6, v6                               // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
v_mul_u32_u24 v7, v6, s[sgprNumWorkGroups0]        // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
v_sub_nc_u32 v7, s[sgprWorkGroup0], v7             // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
v_cmp_eq_u32 vcc_lo, v7, s[sgprNumWorkGroups0]     // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
s_mov_b32 exec_lo, vcc_lo                          // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
v_add_nc_u32 v6, 1, v6                             // s16 = s[sgprWorkGroup0] / s[sgprNumWorkGroups0]
s_mov_b32 exec_lo, -1                              // Reset exec
v_cmp_gt_u32 vcc_lo, v7, s[sgprNumWorkGroups0]     // overflow happened in remainder
s_mov_b32 exec_lo, vcc_lo                          // overflow happened in remainder
v_sub_nc_u32 v6, v6, 1                             // quotient - 1
s_mov_b32 exec_lo, -1                              // Reset exec
v_readfirstlane_b32 s16, v6                        // quotient
s_mov_b32 s[sgprWorkGroup1], s16
/* wg0 = idxWG01 - wg1 * numWG0 */
s_mul_i32 s16, s[sgprWorkGroup1], s[sgprNumWorkGroups0]
s_sub_u32 s[sgprWorkGroup0], s[sgprWorkGroup0], s16

/* Early stop if wg exceed */
s_cmp_ge_u32 s[sgprWorkGroup2], s[sgprSizesFree+2]
s_cbranch_scc0 label_NoEarlyStop_wgExceed
label_EarlyStop_if_wg_exceed:
s_endpgm
label_NoEarlyStop_wgExceed:

label_MultiGemmEnd:
.set sgprSrdA, 48
.set sgprSrdB, 52
.set sgprShadowLimitA, 56
.set sgprShadowLimitB, 58
.set sgprStaggerUIter, 47
.set sgprWrapUA, 60
.set sgprWrapUB, 62
.set sgprGlobalReadIncsA, 64
.set sgprGlobalReadIncsB, 65
.set sgprScalarGlobalReadOffsetA, 66
.set sgprScalarGlobalReadOffsetB, 67
s_sub_u32 s[sgprAddressA+0], s[sgprAddressA+0], 16 // pre-pad to make room for possible pointer shift
s_subb_u32 s[sgprAddressA+1], s[sgprAddressA+1], 0 // pre-pad to make room for possible pointer shift
s_sub_u32 s[sgprAddressB+0], s[sgprAddressB+0], 16 // pre-pad to make room for possible pointer shift
s_subb_u32 s[sgprAddressB+1], s[sgprAddressB+1], 0 // pre-pad to make room for possible pointer shift

/* Short circuit condition if Alpha == 0, then sumDims=0 */
v_cmp_eq_f32 vcc_lo, s[sgprAlpha], 0.0             // s[Alpha] == 0.0f ?
s_cbranch_vccz label_AlphaNonZero                  // branch if s[Alpha] != 0
s_mov_b32 s[sgprSizesSum+0], 0                     // Set summation dim=0 if Alpha == 0
label_AlphaNonZero:
s_setreg_IMM32_b32 hwreg(26,4,1), 1                // Disable WMMA arb stall

/******************************************/
/* Begin setupNewTile                     */
/******************************************/

/* global read addresses: work-group */
/* graWorkGroup mapping */
s_and_b32 s16, s[sgprGSU], 0x3fff                  // Restore GSU
s_cmp_eq_u32 s16, 1                                // GSU == 1 ?
s_cbranch_scc1 label_GSU                           // branch if GSU == 1
// GSU-not-WGMapRR :nwg1 = (size1J + MT1J - 1) / MT1J;
s_and_b32 s16, s[sgprGSU], 0x4000                  // SCC = (GSUWGMRR == 1) ?
s_cbranch_scc1 label_GSUWGMRR                      // branch if GSUWGMRR == 1
s_and_b32 s16, s[sgprGSU], 0x3fff                  // Restore GSU
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_cvt_f32_u32 v6, s16                              // s[sgprWorkGroup1] = s[sgprWorkGroup1] / s16
v_rcp_iflag_f32 v6, v6                             // s[sgprWorkGroup1] = s[sgprWorkGroup1] / s16
v_cvt_f32_u32 v7, s[sgprWorkGroup1]                // s[sgprWorkGroup1] = s[sgprWorkGroup1] / s16
v_mul_f32 v6, v6, v7                               // s[sgprWorkGroup1] = s[sgprWorkGroup1] / s16
v_cvt_u32_f32 v6, v6                               // s[sgprWorkGroup1] = s[sgprWorkGroup1] / s16
v_mul_u32_u24 v7, v6, s16                          // s[sgprWorkGroup1] = s[sgprWorkGroup1] / s16
v_sub_nc_u32 v7, s[sgprWorkGroup1], v7             // s[sgprWorkGroup1] = s[sgprWorkGroup1] / s16
v_cmp_eq_u32 vcc_lo, v7, s16                       // s[sgprWorkGroup1] = s[sgprWorkGroup1] / s16
s_mov_b32 exec_lo, vcc_lo                          // s[sgprWorkGroup1] = s[sgprWorkGroup1] / s16
v_add_nc_u32 v6, 1, v6                             // s[sgprWorkGroup1] = s[sgprWorkGroup1] / s16
v_mov_b32 v7, 0                                    // s[sgprGSUSumIdx] = s[sgprWorkGroup1] % s16
s_mov_b32 exec_lo, -1                              // Reset exec
v_cmp_gt_u32 vcc_lo, v7, s16                       // overflow happened in remainder
s_mov_b32 exec_lo, vcc_lo                          // overflow happened in remainder
v_sub_nc_u32 v6, v6, 1                             // quotient - 1
v_mul_u32_u24 v7, v6, s16                          // re-calculate remainder
v_sub_nc_u32 v7, s[sgprWorkGroup1], v7             // re-calculate remainder
s_mov_b32 exec_lo, -1                              // Reset exec
v_readfirstlane_b32 s[sgprWorkGroup1], v6          // quotient
v_readfirstlane_b32 s[sgprGSUSumIdx], v7           // remainder
s_branch label_GSUWGMRR_End
label_GSUWGMRR:
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_cvt_f32_u32 v6, s[sgprNumWorkGroups1]            // s[sgprGSUSumIdx] = s[sgprWorkGroup1] / s[sgprNumWorkGroups1]
v_rcp_iflag_f32 v6, v6                             // s[sgprGSUSumIdx] = s[sgprWorkGroup1] / s[sgprNumWorkGroups1]
v_cvt_f32_u32 v7, s[sgprWorkGroup1]                // s[sgprGSUSumIdx] = s[sgprWorkGroup1] / s[sgprNumWorkGroups1]
v_mul_f32 v6, v6, v7                               // s[sgprGSUSumIdx] = s[sgprWorkGroup1] / s[sgprNumWorkGroups1]
v_cvt_u32_f32 v6, v6                               // s[sgprGSUSumIdx] = s[sgprWorkGroup1] / s[sgprNumWorkGroups1]
v_mul_u32_u24 v7, v6, s[sgprNumWorkGroups1]        // s[sgprGSUSumIdx] = s[sgprWorkGroup1] / s[sgprNumWorkGroups1]
v_sub_nc_u32 v7, s[sgprWorkGroup1], v7             // s[sgprGSUSumIdx] = s[sgprWorkGroup1] / s[sgprNumWorkGroups1]
v_cmp_eq_u32 vcc_lo, v7, s[sgprNumWorkGroups1]     // s[sgprGSUSumIdx] = s[sgprWorkGroup1] / s[sgprNumWorkGroups1]
s_mov_b32 exec_lo, vcc_lo                          // s[sgprGSUSumIdx] = s[sgprWorkGroup1] / s[sgprNumWorkGroups1]
v_add_nc_u32 v6, 1, v6                             // s[sgprGSUSumIdx] = s[sgprWorkGroup1] / s[sgprNumWorkGroups1]
v_mov_b32 v7, 0                                    // s[sgprWorkGroup1] = s[sgprWorkGroup1] % s[sgprNumWorkGroups1]
s_mov_b32 exec_lo, -1                              // Reset exec
v_cmp_gt_u32 vcc_lo, v7, s[sgprNumWorkGroups1]     // overflow happened in remainder
s_mov_b32 exec_lo, vcc_lo                          // overflow happened in remainder
v_sub_nc_u32 v6, v6, 1                             // quotient - 1
v_mul_u32_u24 v7, v6, s[sgprNumWorkGroups1]        // re-calculate remainder
v_sub_nc_u32 v7, s[sgprWorkGroup1], v7             // re-calculate remainder
s_mov_b32 exec_lo, -1                              // Reset exec
v_readfirstlane_b32 s[sgprGSUSumIdx], v6           // quotient
v_readfirstlane_b32 s[sgprWorkGroup1], v7          // remainder
label_GSUWGMRR_End:
s_mov_b32 s[sgprGSULog2BpeC], 2
s_mov_b32 s[sgprGSULog2BpeD], 2
s_branch label_GSU_End
label_GSU:
s_mov_b64 s[sgprGSUSumIdx:sgprGSUSumIdx+1], 0      // Set GSUSumIdx to 0
s_mov_b32 s[sgprGSULog2BpeC], 2
s_mov_b32 s[sgprGSULog2BpeD], 2
label_GSU_End:
/* WGM Calculation */
s_mov_b32 s16, s[sgprWGM]                          // Restore WGM
s_sext_i32_i16 s16, s16                            // Restore WGM
s_cmp_gt_i32 s16, 1                                // WGM > 1 ?
s_cbranch_scc1 label_WGMPositive                   // branch if WGM > 1
s_cmp_ge_i32 s16, 0                                // WGM >= 0 ?
s_cbranch_scc1 label_WGM                           // branch if WGM >= 0
s_abs_i32 s16, s16                                 // abs(WGM)
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_cvt_f64_u32 v[16:17], s16                        // s17 = s[sgprWorkGroup0] / s16
v_rcp_f64 v[16:17], v[16:17]                       // s17 = s[sgprWorkGroup0] / s16
v_cvt_f64_u32 v[18:19], s[sgprWorkGroup0]          // s17 = s[sgprWorkGroup0] / s16
v_mul_f64 v[16:17], v[16:17], v[18:19]             // s17 = s[sgprWorkGroup0] / s16
v_cvt_u32_f64 v16, v[16:17]                        // s17 = s[sgprWorkGroup0] / s16
v_mul_lo_u32 v17, v16, s16                         // s17 = s[sgprWorkGroup0] / s16
v_sub_nc_u32 v18, s[sgprWorkGroup0], v17           // s17 = s[sgprWorkGroup0] / s16
v_cmp_ge_u32 vcc_lo, v18, s16                      // s17 = s[sgprWorkGroup0] / s16
s_mov_b32 exec_lo, vcc_lo                          // s17 = s[sgprWorkGroup0] / s16
v_add_nc_u32 v16, v16, 1                           // s17 = s[sgprWorkGroup0] / s16
s_mov_b32 exec_lo, -1                              // Reset exec
v_readfirstlane_b32 s17, v16                       // quotient
s_mul_i32 s20, s17, s16                            // quotient * non-magic divisor
s_sub_u32 s20, s[sgprWorkGroup0], s20              // WorkGroup0=remainder
s_mul_i32 s20, s20, s[sgprNumWorkGroups1]          // (wg1 % WGM)*NumWorkGroups1
s_add_u32 s20, s20, s[sgprWorkGroup1]              // wgSerial = wg0 + (wg1 % WGM)*NumWorkGroups1
v_cvt_f64_u32 v[16:17], s16                        // s18 = s[sgprNumWorkGroups0] / s16
v_rcp_f64 v[16:17], v[16:17]                       // s18 = s[sgprNumWorkGroups0] / s16
v_cvt_f64_u32 v[18:19], s[sgprNumWorkGroups0]      // s18 = s[sgprNumWorkGroups0] / s16
v_mul_f64 v[16:17], v[16:17], v[18:19]             // s18 = s[sgprNumWorkGroups0] / s16
v_cvt_u32_f64 v16, v[16:17]                        // s18 = s[sgprNumWorkGroups0] / s16
v_mul_lo_u32 v17, v16, s16                         // s18 = s[sgprNumWorkGroups0] / s16
v_sub_nc_u32 v18, s[sgprNumWorkGroups0], v17       // s18 = s[sgprNumWorkGroups0] / s16
v_cmp_ge_u32 vcc_lo, v18, s16                      // s18 = s[sgprNumWorkGroups0] / s16
s_mov_b32 exec_lo, vcc_lo                          // s18 = s[sgprNumWorkGroups0] / s16
v_add_nc_u32 v16, v16, 1                           // s18 = s[sgprNumWorkGroups0] / s16
s_mov_b32 exec_lo, -1                              // Reset exec
v_readfirstlane_b32 s18, v16                       // quotient
s_mul_i32 s19, s16, s18                            // quotient * non-magic divisor
s_sub_u32 s19, s[sgprNumWorkGroups0], s19          // NumWorkGroups0=remainder
s_cmp_eq_u32 s19, 0                                // remainder == 0 ?
s_cmov_b32 s19, s16                                // remainder = WGM if remainder == 0
s_cmp_ge_u32 s17, s18                              // blockId >= numFullBlocks ?
s_cselect_b32 s18, s19, s16
v_cvt_f64_u32 v[16:17], s18                        // s[sgprWorkGroup1] = s20 / s18
v_rcp_f64 v[16:17], v[16:17]                       // s[sgprWorkGroup1] = s20 / s18
v_cvt_f64_u32 v[18:19], s20                        // s[sgprWorkGroup1] = s20 / s18
v_mul_f64 v[16:17], v[16:17], v[18:19]             // s[sgprWorkGroup1] = s20 / s18
v_cvt_u32_f64 v16, v[16:17]                        // s[sgprWorkGroup1] = s20 / s18
v_mul_lo_u32 v17, v16, s18                         // s[sgprWorkGroup1] = s20 / s18
v_sub_nc_u32 v18, s20, v17                         // s[sgprWorkGroup1] = s20 / s18
v_cmp_ge_u32 vcc_lo, v18, s18                      // s[sgprWorkGroup1] = s20 / s18
s_mov_b32 exec_lo, vcc_lo                          // s[sgprWorkGroup1] = s20 / s18
v_add_nc_u32 v16, v16, 1                           // s[sgprWorkGroup1] = s20 / s18
s_mov_b32 exec_lo, -1                              // Reset exec
v_mul_lo_u32 v17, v16, s18                         // s[sgprWorkGroup1] = s20 / s18
v_sub_nc_u32 v18, s20, v17                         // s[sgprWorkGroup1] = s20 / s18
v_readfirstlane_b32 s[sgprWorkGroup1], v16         // quotient
v_readfirstlane_b32 s[sgprWorkGroup0], v18         // remainder
s_mul_i32 s[sgprWorkGroup0], s[sgprWorkGroup1], s18 // quotient * non-magic divisor
s_sub_u32 s[sgprWorkGroup0], s20, s[sgprWorkGroup0] // WorkGroup0=remainder
s_mul_i32 s17, s17, s16                            // blockId * WGM
s_add_u32 s[sgprWorkGroup0], s[sgprWorkGroup0], s17 // wg1 += blockId * WGM
s_branch label_WGM
label_WGMPositive:
s_mov_b32 s16, s16                                 // WGM
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_cvt_f64_u32 v[16:17], s16                        // s17 = s[sgprWorkGroup1] / s16
v_rcp_f64 v[16:17], v[16:17]                       // s17 = s[sgprWorkGroup1] / s16
v_cvt_f64_u32 v[18:19], s[sgprWorkGroup1]          // s17 = s[sgprWorkGroup1] / s16
v_mul_f64 v[16:17], v[16:17], v[18:19]             // s17 = s[sgprWorkGroup1] / s16
v_cvt_u32_f64 v16, v[16:17]                        // s17 = s[sgprWorkGroup1] / s16
v_mul_lo_u32 v17, v16, s16                         // s17 = s[sgprWorkGroup1] / s16
v_sub_nc_u32 v18, s[sgprWorkGroup1], v17           // s17 = s[sgprWorkGroup1] / s16
v_cmp_ge_u32 vcc_lo, v18, s16                      // s17 = s[sgprWorkGroup1] / s16
s_mov_b32 exec_lo, vcc_lo                          // s17 = s[sgprWorkGroup1] / s16
v_add_nc_u32 v16, v16, 1                           // s17 = s[sgprWorkGroup1] / s16
s_mov_b32 exec_lo, -1                              // Reset exec
v_readfirstlane_b32 s17, v16                       // quotient
s_mul_i32 s20, s17, s16                            // quotient * non-magic divisor
s_sub_u32 s20, s[sgprWorkGroup1], s20              // WorkGroup1=remainder
s_mul_i32 s20, s20, s[sgprNumWorkGroups0]          // (wg1 % WGM)*NumWorkGroups0
s_add_u32 s20, s20, s[sgprWorkGroup0]              // wgSerial = wg0 + (wg1 % WGM)*NumWorkGroups0
v_cvt_f64_u32 v[16:17], s16                        // s18 = s[sgprNumWorkGroups1] / s16
v_rcp_f64 v[16:17], v[16:17]                       // s18 = s[sgprNumWorkGroups1] / s16
v_cvt_f64_u32 v[18:19], s[sgprNumWorkGroups1]      // s18 = s[sgprNumWorkGroups1] / s16
v_mul_f64 v[16:17], v[16:17], v[18:19]             // s18 = s[sgprNumWorkGroups1] / s16
v_cvt_u32_f64 v16, v[16:17]                        // s18 = s[sgprNumWorkGroups1] / s16
v_mul_lo_u32 v17, v16, s16                         // s18 = s[sgprNumWorkGroups1] / s16
v_sub_nc_u32 v18, s[sgprNumWorkGroups1], v17       // s18 = s[sgprNumWorkGroups1] / s16
v_cmp_ge_u32 vcc_lo, v18, s16                      // s18 = s[sgprNumWorkGroups1] / s16
s_mov_b32 exec_lo, vcc_lo                          // s18 = s[sgprNumWorkGroups1] / s16
v_add_nc_u32 v16, v16, 1                           // s18 = s[sgprNumWorkGroups1] / s16
s_mov_b32 exec_lo, -1                              // Reset exec
v_readfirstlane_b32 s18, v16                       // quotient
s_mul_i32 s19, s16, s18                            // quotient * non-magic divisor
s_sub_u32 s19, s[sgprNumWorkGroups1], s19          // NumWorkGroups1=remainder
s_cmp_eq_u32 s19, 0                                // remainder == 0 ?
s_cmov_b32 s19, s16                                // remainder = WGM if remainder == 0
s_cmp_ge_u32 s17, s18                              // blockId >= numFullBlocks ?
s_cselect_b32 s18, s19, s16
v_cvt_f64_u32 v[16:17], s18                        // s[sgprWorkGroup0] = s20 / s18
v_rcp_f64 v[16:17], v[16:17]                       // s[sgprWorkGroup0] = s20 / s18
v_cvt_f64_u32 v[18:19], s20                        // s[sgprWorkGroup0] = s20 / s18
v_mul_f64 v[16:17], v[16:17], v[18:19]             // s[sgprWorkGroup0] = s20 / s18
v_cvt_u32_f64 v16, v[16:17]                        // s[sgprWorkGroup0] = s20 / s18
v_mul_lo_u32 v17, v16, s18                         // s[sgprWorkGroup0] = s20 / s18
v_sub_nc_u32 v18, s20, v17                         // s[sgprWorkGroup0] = s20 / s18
v_cmp_ge_u32 vcc_lo, v18, s18                      // s[sgprWorkGroup0] = s20 / s18
s_mov_b32 exec_lo, vcc_lo                          // s[sgprWorkGroup0] = s20 / s18
v_add_nc_u32 v16, v16, 1                           // s[sgprWorkGroup0] = s20 / s18
s_mov_b32 exec_lo, -1                              // Reset exec
v_mul_lo_u32 v17, v16, s18                         // s[sgprWorkGroup0] = s20 / s18
v_sub_nc_u32 v18, s20, v17                         // s[sgprWorkGroup0] = s20 / s18
v_readfirstlane_b32 s[sgprWorkGroup0], v16         // quotient
v_readfirstlane_b32 s[sgprWorkGroup1], v18         // remainder
s_mul_i32 s[sgprWorkGroup1], s[sgprWorkGroup0], s18 // quotient * non-magic divisor
s_sub_u32 s[sgprWorkGroup1], s20, s[sgprWorkGroup1] // WorkGroup1=remainder
s_mul_i32 s17, s17, s16                            // blockId * WGM
s_add_u32 s[sgprWorkGroup1], s[sgprWorkGroup1], s17 // wg1 += blockId * WGM
label_WGM:

/* global read addresses: tile offset assignment a */
/* graTileAssignmentA = v0 */

/* global read addresses: tile offset assignment b */
/* graTileAssignmentB = v2 */

/* global read addresses: unroll assignment a */
/* v1 */

/* global read addresses: unroll assignment b */
/* v3 */

/* global read addresses: other free assignments */
/* s[sgprWorkGroup2] */

/* global read addresses: tile offsets a */

/* global read addresses: tile offsets b */

/* global read addresses: unroll offsets a */

/* global read addresses: unroll offsets b */

/* global read addresses: addresses a */
/* max read offset = size[n] * stride[n-1] */
s_mul_hi_u32 s19, s[sgprWorkGroup0], 32            // WorkGroup[01] * MT
s_mul_i32 s18, s[sgprWorkGroup0], 32               // WorkGroup[01] * MT
s_mul_hi_u32 s19, s18, s[sgprStrideA0I]            // tlu=0, scaled tile-offset by stride
s_mul_i32 s18, s18, s[sgprStrideA0I]               // tlu=0, scaled tile-offset by stride
s_and_b32 s16, s[sgprGSU], 0x8000                  // SCC = (GSUC == 1) ?
s_cbranch_scc1 label_GSUC_A                        // branch if GSUC == 1
s_mul_hi_u32 s17, 32, s[sgprGSUSumIdx]             // gsuOffset = DepthU*GSUSumIdx
s_mul_i32 s16, 32, s[sgprGSUSumIdx]                // gsuOffset = DepthU*GSUSumIdx
s_branch label_GSUC_A_End
label_GSUC_A:
s_lshr_b32 s[sgprLoopCounterL], s[sgprSizesSum], 5 // s[LoopCounterL] = s[sgprSizesSum] / 32
s_and_b32 s[sgprGSUSumIdx+1], s[sgprGSU], 0x3fff   // Restore GSU
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_cvt_f32_u32 v6, s[sgprGSUSumIdx+1]               // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_rcp_iflag_f32 v6, v6                             // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_cvt_f32_u32 v7, s[sgprLoopCounterL]              // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_mul_f32 v6, v6, v7                               // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_cvt_u32_f32 v6, v6                               // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_mul_u32_u24 v7, v6, s[sgprGSUSumIdx+1]           // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_sub_nc_u32 v7, s[sgprLoopCounterL], v7           // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_cmp_eq_u32 vcc_lo, v7, s[sgprGSUSumIdx+1]        // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
s_mov_b32 exec_lo, vcc_lo                          // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_add_nc_u32 v6, 1, v6                             // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_mov_b32 v7, 0                                    // s[sgprGSUSumIdx+1] = s[sgprLoopCounterL] % s[sgprGSUSumIdx+1]
s_mov_b32 exec_lo, -1                              // Reset exec
v_cmp_gt_u32 vcc_lo, v7, s[sgprGSUSumIdx+1]        // overflow happened in remainder
s_mov_b32 exec_lo, vcc_lo                          // overflow happened in remainder
v_sub_nc_u32 v6, v6, 1                             // quotient - 1
v_mul_u32_u24 v7, v6, s[sgprGSUSumIdx+1]           // re-calculate remainder
v_sub_nc_u32 v7, s[sgprLoopCounterL], v7           // re-calculate remainder
s_mov_b32 exec_lo, -1                              // Reset exec
v_readfirstlane_b32 s[sgprLoopCounterL], v6        // quotient
v_readfirstlane_b32 s[sgprGSUSumIdx+1], v7         // remainder
s_mul_i32 s17, s[sgprLoopCounterL], s[sgprGSUSumIdx] // quotient*GSUSumIdx
s_add_u32 s16, 1, s[sgprLoopCounterL]              // quotient+1
s_add_u32 s17, s17, s[sgprGSUSumIdx+1]             // quotient*GSUSumIdx+remainder
s_mul_i32 s16, s16, s[sgprGSUSumIdx]               // (quotient+1)*GSUSumIdx
s_cmp_lt_u32 s[sgprGSUSumIdx], s[sgprGSUSumIdx+1]  // gsuSumIdx < numIterPerWgRemainder
s_cselect_b32 s16, s16, s17                        // (quotient+1)*GSUSumIdx if needed
s_mul_hi_u32 s17, s16, 32                          // gsuOffset = DepthU*accumulatedNumOfLoopCounterL
s_mul_i32 s16, s16, 32                             // gsuOffset = DepthU*accumulatedNumOfLoopCounterL
label_GSUC_A_End:
s_add_u32 s18, s18, s16                            // accum GsuOffset term to tilestart
s_addc_u32 s19, s19, s17                           // accum GsuOffset term to tilestart
s_mov_b64 s[sgprShadowLimitA+0:sgprShadowLimitA+0+1], 1 // Init tensor size
s_sub_u32 s16, s[sgprSizeL], 1                     // (size-1)
s_mul_hi_u32 s17, constStrideAL, s16               // stride x (size-1)
s_mul_i32 s16, constStrideAL, s16                  // stride x (size-1)
s_add_u32 s[sgprShadowLimitA+0], s[sgprShadowLimitA+0], s16 // sum tensor size
s_addc_u32 s[sgprShadowLimitA+1], s[sgprShadowLimitA+1], s17 // sum tensor size
s_sub_u32 s16, s[sgprSizeI], 1                     // (size-1)
s_mul_hi_u32 s17, s[sgprStrideA0I], s16            // stride x (size-1)
s_mul_i32 s16, s[sgprStrideA0I], s16               // stride x (size-1)
s_add_u32 s[sgprShadowLimitA+0], s[sgprShadowLimitA+0], s16 // sum tensor size
s_addc_u32 s[sgprShadowLimitA+1], s[sgprShadowLimitA+1], s17 // sum tensor size
s_sub_u32 s[sgprShadowLimitA+0], s[sgprShadowLimitA+0], s18 // sub tileStart
s_subb_u32 s[sgprShadowLimitA+1], s[sgprShadowLimitA+1], s19 // sub tileStart
s_lshl_b64 s[sgprShadowLimitA:sgprShadowLimitA+1], s[sgprShadowLimitA:sgprShadowLimitA+1], 2 // Set limit to use bytes (multiple bpe)
s_add_u32 s[sgprShadowLimitA+0], s[sgprShadowLimitA+0], 16 // extend limit for pre-pad
s_addc_u32 s[sgprShadowLimitA+1], s[sgprShadowLimitA+1], 0 // extend limit for pre-pad
s_cmp_eq_u32 s[sgprShadowLimitA+1], 0              // are we within 2^32?
s_cselect_b32 s[sgprSrdA+2], s[sgprShadowLimitA+0], BufferLimit // Move shadow to real if we are within 2^32
// Shift num records for gfx125x
s_and_b32 s20, s[sgprSrdA+2], 127
s_lshl_b32 s20, s20, 25
s_and_b32 s[sgprSrdA+1], s[sgprSrdA+1], 33554431
s_or_b32 s[sgprSrdA+1], s[sgprSrdA+1], s20
s_lshr_b32 s[sgprSrdA+2], s[sgprSrdA+2], 7
s_mul_hi_u32 s17, s[sgprStrideAK], s[sgprWorkGroup2] // Stride*WG
s_mul_i32 s16, s[sgprStrideAK], s[sgprWorkGroup2]  // Stride*WG
s_add_u32 s18, s18, s16                            // accum wg term to tilestart
s_addc_u32 s19, s19, s17                           // accum wg term to tilestart
s_lshl_b64 s[18:19], s[18:19], 2                   // tileStart (multiple bpe)
s_add_u32 s[sgprSrdA+0], s[sgprAddressA+0], s18    // SRD base = Address+ tileStart0
s_addc_u32 s[sgprSrdA+1], s[sgprAddressA+1], s19   // SRD base = Address+ tileStart1
s_mov_b32 s[sgprSrdA+3], Srd127_96                 // Set bits 127_96 in SRD

/* global read addresses: addresses b */
/* max read offset = size[n] * stride[n-1] */
s_mul_hi_u32 s19, s[sgprWorkGroup1], 32            // WorkGroup[01] * MT
s_mul_i32 s18, s[sgprWorkGroup1], 32               // WorkGroup[01] * MT
s_mul_hi_u32 s19, s18, s[sgprStrideB1J]            // tlu=0, scaled tile-offset by stride
s_mul_i32 s18, s18, s[sgprStrideB1J]               // tlu=0, scaled tile-offset by stride
s_and_b32 s16, s[sgprGSU], 0x8000                  // SCC = (GSUC == 1) ?
s_cbranch_scc1 label_GSUC_B                        // branch if GSUC == 1
s_mul_hi_u32 s17, 32, s[sgprGSUSumIdx]             // gsuOffset = DepthU*GSUSumIdx
s_mul_i32 s16, 32, s[sgprGSUSumIdx]                // gsuOffset = DepthU*GSUSumIdx
s_branch label_GSUC_B_End
label_GSUC_B:
s_lshr_b32 s[sgprLoopCounterL], s[sgprSizesSum], 5 // s[LoopCounterL] = s[sgprSizesSum] / 32
s_and_b32 s[sgprGSUSumIdx+1], s[sgprGSU], 0x3fff   // Restore GSU
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_cvt_f32_u32 v6, s[sgprGSUSumIdx+1]               // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_rcp_iflag_f32 v6, v6                             // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_cvt_f32_u32 v7, s[sgprLoopCounterL]              // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_mul_f32 v6, v6, v7                               // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_cvt_u32_f32 v6, v6                               // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_mul_u32_u24 v7, v6, s[sgprGSUSumIdx+1]           // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_sub_nc_u32 v7, s[sgprLoopCounterL], v7           // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_cmp_eq_u32 vcc_lo, v7, s[sgprGSUSumIdx+1]        // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
s_mov_b32 exec_lo, vcc_lo                          // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_add_nc_u32 v6, 1, v6                             // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_mov_b32 v7, 0                                    // s[sgprGSUSumIdx+1] = s[sgprLoopCounterL] % s[sgprGSUSumIdx+1]
s_mov_b32 exec_lo, -1                              // Reset exec
v_cmp_gt_u32 vcc_lo, v7, s[sgprGSUSumIdx+1]        // overflow happened in remainder
s_mov_b32 exec_lo, vcc_lo                          // overflow happened in remainder
v_sub_nc_u32 v6, v6, 1                             // quotient - 1
v_mul_u32_u24 v7, v6, s[sgprGSUSumIdx+1]           // re-calculate remainder
v_sub_nc_u32 v7, s[sgprLoopCounterL], v7           // re-calculate remainder
s_mov_b32 exec_lo, -1                              // Reset exec
v_readfirstlane_b32 s[sgprLoopCounterL], v6        // quotient
v_readfirstlane_b32 s[sgprGSUSumIdx+1], v7         // remainder
s_mul_i32 s17, s[sgprLoopCounterL], s[sgprGSUSumIdx] // quotient*GSUSumIdx
s_add_u32 s16, 1, s[sgprLoopCounterL]              // quotient+1
s_add_u32 s17, s17, s[sgprGSUSumIdx+1]             // quotient*GSUSumIdx+remainder
s_mul_i32 s16, s16, s[sgprGSUSumIdx]               // (quotient+1)*GSUSumIdx
s_cmp_lt_u32 s[sgprGSUSumIdx], s[sgprGSUSumIdx+1]  // gsuSumIdx < numIterPerWgRemainder
s_cselect_b32 s16, s16, s17                        // (quotient+1)*GSUSumIdx if needed
s_mul_hi_u32 s17, s16, 32                          // gsuOffset = DepthU*accumulatedNumOfLoopCounterL
s_mul_i32 s16, s16, 32                             // gsuOffset = DepthU*accumulatedNumOfLoopCounterL
label_GSUC_B_End:
s_add_u32 s18, s18, s16                            // accum GsuOffset term to tilestart
s_addc_u32 s19, s19, s17                           // accum GsuOffset term to tilestart
s_mov_b64 s[sgprShadowLimitB+0:sgprShadowLimitB+0+1], 1 // Init tensor size
s_sub_u32 s16, s[sgprSizeL], 1                     // (size-1)
s_mul_hi_u32 s17, constStrideBL, s16               // stride x (size-1)
s_mul_i32 s16, constStrideBL, s16                  // stride x (size-1)
s_add_u32 s[sgprShadowLimitB+0], s[sgprShadowLimitB+0], s16 // sum tensor size
s_addc_u32 s[sgprShadowLimitB+1], s[sgprShadowLimitB+1], s17 // sum tensor size
s_sub_u32 s16, s[sgprSizeJ], 1                     // (size-1)
s_mul_hi_u32 s17, s[sgprStrideB1J], s16            // stride x (size-1)
s_mul_i32 s16, s[sgprStrideB1J], s16               // stride x (size-1)
s_add_u32 s[sgprShadowLimitB+0], s[sgprShadowLimitB+0], s16 // sum tensor size
s_addc_u32 s[sgprShadowLimitB+1], s[sgprShadowLimitB+1], s17 // sum tensor size
s_sub_u32 s[sgprShadowLimitB+0], s[sgprShadowLimitB+0], s18 // sub tileStart
s_subb_u32 s[sgprShadowLimitB+1], s[sgprShadowLimitB+1], s19 // sub tileStart
s_lshl_b64 s[sgprShadowLimitB:sgprShadowLimitB+1], s[sgprShadowLimitB:sgprShadowLimitB+1], 2 // Set limit to use bytes (multiple bpe)
s_add_u32 s[sgprShadowLimitB+0], s[sgprShadowLimitB+0], 16 // extend limit for pre-pad
s_addc_u32 s[sgprShadowLimitB+1], s[sgprShadowLimitB+1], 0 // extend limit for pre-pad
s_cmp_eq_u32 s[sgprShadowLimitB+1], 0              // are we within 2^32?
s_cselect_b32 s[sgprSrdB+2], s[sgprShadowLimitB+0], BufferLimit // Move shadow to real if we are within 2^32
// Shift num records for gfx125x
s_and_b32 s20, s[sgprSrdB+2], 127
s_lshl_b32 s20, s20, 25
s_and_b32 s[sgprSrdB+1], s[sgprSrdB+1], 33554431
s_or_b32 s[sgprSrdB+1], s[sgprSrdB+1], s20
s_lshr_b32 s[sgprSrdB+2], s[sgprSrdB+2], 7
s_mul_hi_u32 s17, s[sgprStrideBK], s[sgprWorkGroup2] // Stride*WG
s_mul_i32 s16, s[sgprStrideBK], s[sgprWorkGroup2]  // Stride*WG
s_add_u32 s18, s18, s16                            // accum wg term to tilestart
s_addc_u32 s19, s19, s17                           // accum wg term to tilestart
s_lshl_b64 s[18:19], s[18:19], 2                   // tileStart (multiple bpe)
s_add_u32 s[sgprSrdB+0], s[sgprAddressB+0], s18    // SRD base = Address+ tileStart0
s_addc_u32 s[sgprSrdB+1], s[sgprAddressB+1], s19   // SRD base = Address+ tileStart1
s_mov_b32 s[sgprSrdB+3], Srd127_96                 // Set bits 127_96 in SRD

/* global read addresses: final offsets a */
/* ============================================================= */

/* Global Offset A */
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_mul_lo_u32 v16, s[sgprStrideA0I], v0             // mul d1 lower
v_add_co_u32 v[vgprGlobalReadOffsetA+0], vcc_lo, v1, v16 // accumulate K lower
v_add_nc_u32 v[vgprGlobalReadOffsetA+0], 0x4, v[vgprGlobalReadOffsetA+0] // add prepad for pointer shift

/* Global Offset A (end) */
v_lshlrev_b32 v[vgprGlobalReadOffsetA+0], 2, v[vgprGlobalReadOffsetA+0] //  (multiple bpe)
s_mul_i32 s[sgprScalarGlobalReadOffsetA+0], s[sgprStrideA0I], 16 // compute offset diff (scaled tileDim)
s_lshl_b32 s[sgprScalarGlobalReadOffsetA+0], s[sgprScalarGlobalReadOffsetA+0], 2 //  (multiple bpe)
/* ============================================================= */

/* global read addresses: final offsets b */
/* ============================================================= */

/* Global Offset B */
v_mul_lo_u32 v16, s[sgprStrideB1J], v2             // mul d1 lower
v_add_co_u32 v[vgprGlobalReadOffsetB+0], vcc_lo, v3, v16 // accumulate K lower
v_add_nc_u32 v[vgprGlobalReadOffsetB+0], 0x4, v[vgprGlobalReadOffsetB+0] // add prepad for pointer shift

/* Global Offset B (end) */
v_lshlrev_b32 v[vgprGlobalReadOffsetB+0], 2, v[vgprGlobalReadOffsetB+0] //  (multiple bpe)
s_mul_i32 s[sgprScalarGlobalReadOffsetB+0], s[sgprStrideB1J], 16 // compute offset diff (scaled tileDim)
s_lshl_b32 s[sgprScalarGlobalReadOffsetB+0], s[sgprScalarGlobalReadOffsetB+0], 2 //  (multiple bpe)
/* ============================================================= */

/* global read addresses: increments a */
s_and_b32 s17, s[sgprGSU], 0x3fff                  // Restore GSU
s_mul_i32 s17, s17, 128                            // GSU*DepthU*Bpe*MI_dim(1)
s_and_b32 s16, s[sgprGSU], 0x8000                  // SCC = (GSUC == 1) ?
s_cselect_b32 s[sgprGlobalReadIncsA+0], 128, s17   // incrA (unrollIdx)

/* global read addresses: increments b */
s_and_b32 s17, s[sgprGSU], 0x3fff                  // Restore GSU
s_mul_i32 s17, s17, 128                            // GSU*DepthU*Bpe*MI_dim(1)
s_and_b32 s16, s[sgprGSU], 0x8000                  // SCC = (GSUC == 1) ?
s_cselect_b32 s[sgprGlobalReadIncsB+0], 128, s17   // incrB (unrollIdx)
/* declare loop num iterations */
s_lshr_b32 s[sgprLoopCounterL], s[sgprSizesSum+0], 5 // s[sgprLoopCounterL] = s[sgprSizesSum+0] / 32
s_and_b32 s16, s[sgprGSU], 0x3fff                  // Restore GSU
s_cmp_eq_u32 s16, 1                                // GSU == 1 ?
s_cbranch_scc1 label_GSU_1                         // branch if GSU == 1
s_and_b32 s[sgprGSUSumIdx+1], s[sgprGSU], 0x3fff   // Restore GSU
v_cvt_f32_u32 v0, s[sgprGSUSumIdx+1]               // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_rcp_iflag_f32 v0, v0                             // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_cvt_f32_u32 v1, s[sgprLoopCounterL]              // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_mul_f32 v0, v0, v1                               // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_cvt_u32_f32 v0, v0                               // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_mul_u32_u24 v1, v0, s[sgprGSUSumIdx+1]           // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_sub_nc_u32 v1, s[sgprLoopCounterL], v1           // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_cmp_eq_u32 vcc_lo, v1, s[sgprGSUSumIdx+1]        // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
s_mov_b32 exec_lo, vcc_lo                          // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_add_nc_u32 v0, 1, v0                             // s[sgprLoopCounterL] = s[sgprLoopCounterL] / s[sgprGSUSumIdx+1]
v_mov_b32 v1, 0                                    // s[sgprGSUSumIdx+1] = s[sgprLoopCounterL] % s[sgprGSUSumIdx+1]
s_mov_b32 exec_lo, -1                              // Reset exec
v_cmp_gt_u32 vcc_lo, v1, s[sgprGSUSumIdx+1]        // overflow happened in remainder
s_mov_b32 exec_lo, vcc_lo                          // overflow happened in remainder
v_sub_nc_u32 v0, v0, 1                             // quotient - 1
v_mul_u32_u24 v1, v0, s[sgprGSUSumIdx+1]           // re-calculate remainder
v_sub_nc_u32 v1, s[sgprLoopCounterL], v1           // re-calculate remainder
s_mov_b32 exec_lo, -1                              // Reset exec
v_readfirstlane_b32 s[sgprLoopCounterL], v0        // quotient
v_readfirstlane_b32 s[sgprGSUSumIdx+1], v1         // remainder
s_add_u32 s16, 1, s[sgprLoopCounterL]              // tmp<-numIterMyWg+1
s_cmp_lt_u32 s[sgprGSUSumIdx], s[sgprGSUSumIdx+1]  // gsuSumIdx < numIterPerWgRemainder
s_cmov_b32 s[sgprLoopCounterL], s16                // numIterMyWg++ if needed
label_GSU_1:
s_mov_b32 s[sgprOrigLoopCounter], s[sgprLoopCounterL] // copy loop counter
s_and_b32 s18, s[sgprStaggerU], 0x1f00
s_lshr_b32 s18, s18, 0x8
s_and_b32 s19, s[sgprStaggerU], 0xe000
s_and_b32 s[sgprStaggerU], s[sgprStaggerU], 0xff
s_mov_b32 s16, s[sgprStaggerU]                     // init staggerU
label_beginStaggerUIter:
s_lshl_b32 s17, s16, s18                           // shift by StaggerUStride
s_cmp_ge_u32 s[sgprOrigLoopCounter], s17           // loopCount >= current shift Count
s_cbranch_scc1 label_endStaggerUIter               // jump to end
s_lshr_b32 s16, s16, 1                             // step down to smaller stagger
s_branch label_beginStaggerUIter                   // jump to begin
label_endStaggerUIter:
s_sub_u32 s17, s16, 1                              // staggerU mask
s_cmp_ge_u32 s16, 1                                // if current staggerU >= 1
s_cselect_b32 s[sgprStaggerUIter], s17, 0          // set Mask
s_cmp_eq_u32 s19, 0x0
s_cbranch_scc0 label_StaggerUMapping_1
s_mov_b32 s16, s[sgprWorkGroup0]
s_branch label_staggerInputEnd
label_StaggerUMapping_1:
s_cmp_eq_u32 s19, 0x2000
s_cbranch_scc0 label_StaggerUMapping_2
s_mov_b32 s16, s[sgprWorkGroup1]
s_branch label_staggerInputEnd
label_StaggerUMapping_2:
s_cmp_eq_u32 s19, 0x4000
s_cbranch_scc0 label_StaggerUMapping_3
s_mov_b32 s16, -0x1
s_branch label_staggerInputEnd
label_StaggerUMapping_3:
s_cmp_eq_u32 s19, 0x6000
s_cbranch_scc0 label_StaggerUMapping_4
s_mul_i32 s17, s[sgprNumWorkGroups0], s[sgprWorkGroup1]
s_add_u32 s16, s16, s17
s_add_u32 s16, s16, s[sgprWorkGroup0]
s_branch label_staggerInputEnd
label_StaggerUMapping_4:
s_cmp_eq_u32 s19, 0x8000
s_cbranch_scc0 label_staggerInputEnd
s_mov_b32 s16, -0x1
s_branch label_staggerInputEnd
label_staggerInputEnd:
s_and_b32 s[sgprStaggerUIter], s[sgprStaggerUIter], s16 // Compute actual stagger start for this tile
s_lshl_b32 s[sgprStaggerUIter], s[sgprStaggerUIter], s18 // shift by StaggerUStride

/* SRDs += (StaggerUIter) * GlobalReadIncsA+0 */
s_mul_hi_i32 s17, s[sgprStaggerUIter], s[sgprGlobalReadIncsA+0] //  stagger byte offset
s_mul_i32 s16, s[sgprStaggerUIter], s[sgprGlobalReadIncsA+0] //  stagger byte offset
s_mul_hi_i32 s[sgprWrapUA+1], s[sgprLoopCounterL], s[sgprGlobalReadIncsA+0] // Number of bytes accessed by the unroll loop
s_mul_i32 s[sgprWrapUA+0], s[sgprLoopCounterL], s[sgprGlobalReadIncsA+0] // Number of bytes accessed by the unroll loop
s_mov_b32 s20, s[sgprGlobalReadIncsA+0]
s_mov_b32 s21, 0
s_sub_u64 s[sgprWrapUA:sgprWrapUA+1], s[20:21], s[sgprWrapUA:sgprWrapUA+1] // increment-WrapU
s_add_u32 s[sgprSrdA+0], s[sgprSrdA+0], s16        // gra SRD += inc(lower)
s_addc_u32 s[sgprSrdA+1], s[sgprSrdA+1], s17       // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitA+0], s[sgprShadowLimitA+0], s16 // limit -= inc)
s_subb_u32 s[sgprShadowLimitA+1], s[sgprShadowLimitA+1], s17 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitA+1], 0              // are we within 2^32?
s_cselect_b32 s[sgprSrdA+2], s[sgprShadowLimitA+0], BufferLimit // Move shadow to real if we are within 2^32
// Shift num records for gfx125x
s_and_b32 s19, s[sgprSrdA+2], 127
s_lshl_b32 s19, s19, 25
s_and_b32 s[sgprSrdA+1], s[sgprSrdA+1], 33554431
s_or_b32 s[sgprSrdA+1], s[sgprSrdA+1], s19
s_lshr_b32 s[sgprSrdA+2], s[sgprSrdA+2], 7

/* SRDs += (StaggerUIter) * GlobalReadIncsB+0 */
s_mul_hi_i32 s17, s[sgprStaggerUIter], s[sgprGlobalReadIncsB+0] //  stagger byte offset
s_mul_i32 s16, s[sgprStaggerUIter], s[sgprGlobalReadIncsB+0] //  stagger byte offset
s_mul_hi_i32 s[sgprWrapUB+1], s[sgprLoopCounterL], s[sgprGlobalReadIncsB+0] // Number of bytes accessed by the unroll loop
s_mul_i32 s[sgprWrapUB+0], s[sgprLoopCounterL], s[sgprGlobalReadIncsB+0] // Number of bytes accessed by the unroll loop
s_mov_b32 s20, s[sgprGlobalReadIncsB+0]
s_sub_u64 s[sgprWrapUB:sgprWrapUB+1], s[20:21], s[sgprWrapUB:sgprWrapUB+1] // increment-WrapU
s_add_u32 s[sgprSrdB+0], s[sgprSrdB+0], s16        // gra SRD += inc(lower)
s_addc_u32 s[sgprSrdB+1], s[sgprSrdB+1], s17       // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitB+0], s[sgprShadowLimitB+0], s16 // limit -= inc)
s_subb_u32 s[sgprShadowLimitB+1], s[sgprShadowLimitB+1], s17 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitB+1], 0              // are we within 2^32?
s_cselect_b32 s[sgprSrdB+2], s[sgprShadowLimitB+0], BufferLimit // Move shadow to real if we are within 2^32
// Shift num records for gfx125x
s_and_b32 s19, s[sgprSrdB+2], 127
s_lshl_b32 s19, s19, 25
s_and_b32 s[sgprSrdB+1], s[sgprSrdB+1], 33554431
s_or_b32 s[sgprSrdB+1], s[sgprSrdB+1], s19
s_lshr_b32 s[sgprSrdB+2], s[sgprSrdB+2], 7
s_add_u32 s[sgprStaggerUIter], s[sgprStaggerUIter], 2 // Subtract (PGR-1); StaggerUIter now contains target iteration to wrap
/* local read addresses: init pointers a */

/* localReadInitPointers */
/* local read addresses: init pointers b */

/* localReadInitPointers */

/* prefetch: global -> local */
s_cmp_eq_u32 s[sgprLoopCounterL], 0                // at last iteration?
s_cbranch_scc1 label_ShadowInitStart               // skip to ShadowInitStart iter b/c numIter==0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
buffer_load_b128 v[vgprG2LA+0:vgprG2LA+0+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], null offen offset:0 // G -> Reg 0_0_0_0
buffer_load_b128 v[vgprG2LA+4:vgprG2LA+4+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], s[sgprScalarGlobalReadOffsetA+0] offen offset:0 // G -> Reg 0_0_1_0
buffer_load_b128 v[vgprG2LB+0:vgprG2LB+0+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], null offen offset:0 // G -> Reg 0_0_0_0
buffer_load_b128 v[vgprG2LB+4:vgprG2LB+4+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+0] offen offset:0 // G -> Reg 0_0_1_0

/* global read inc A loopL */
s_add_u32 s18, s[sgprLoopCounterL], 1              // remove pf(1)
s_cmp_eq_u32 s[sgprStaggerUIter], s18              // Is this wrapIter? (pf)
s_cselect_b32 s16, s[sgprWrapUA+0], s[sgprGlobalReadIncsA+0] // incLower <- ?
s_cselect_b32 s17, s[sgprWrapUA+1], 0              // incUpper <- ?
s_add_u32 s[sgprSrdA+0], s[sgprSrdA+0], s16        // gra SRD += inc(lower)
s_addc_u32 s[sgprSrdA+1], s[sgprSrdA+1], s17       // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitA+0], s[sgprShadowLimitA+0], s16 // limit -= inc)
s_subb_u32 s[sgprShadowLimitA+1], s[sgprShadowLimitA+1], s17 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitA+1], 0              // are we within 2^32?
s_cselect_b32 s[sgprSrdA+2], s[sgprShadowLimitA+0], BufferLimit // Move shadow to real if we are within 2^32
// Shift num records for gfx125x
s_and_b32 s20, s[sgprSrdA+2], 127
s_lshl_b32 s20, s20, 25
s_and_b32 s[sgprSrdA+1], s[sgprSrdA+1], 33554431
s_or_b32 s[sgprSrdA+1], s[sgprSrdA+1], s20
s_lshr_b32 s[sgprSrdA+2], s[sgprSrdA+2], 7

/* global read inc B loopL */
s_add_u32 s18, s[sgprLoopCounterL], 1              // remove pf(1)
s_cmp_eq_u32 s[sgprStaggerUIter], s18              // Is this wrapIter? (pf)
s_cselect_b32 s16, s[sgprWrapUB+0], s[sgprGlobalReadIncsB+0] // incLower <- ?
s_cselect_b32 s17, s[sgprWrapUB+1], 0              // incUpper <- ?
s_add_u32 s[sgprSrdB+0], s[sgprSrdB+0], s16        // gra SRD += inc(lower)
s_addc_u32 s[sgprSrdB+1], s[sgprSrdB+1], s17       // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitB+0], s[sgprShadowLimitB+0], s16 // limit -= inc)
s_subb_u32 s[sgprShadowLimitB+1], s[sgprShadowLimitB+1], s17 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitB+1], 0              // are we within 2^32?
s_cselect_b32 s[sgprSrdB+2], s[sgprShadowLimitB+0], BufferLimit // Move shadow to real if we are within 2^32
// Shift num records for gfx125x
s_and_b32 s20, s[sgprSrdB+2], 127
s_lshl_b32 s20, s20, 25
s_and_b32 s[sgprSrdB+1], s[sgprSrdB+1], 33554431
s_or_b32 s[sgprSrdB+1], s[sgprSrdB+1], s20
s_lshr_b32 s[sgprSrdB+2], s[sgprSrdB+2], 7

/******************************************/
/* End setupNewTile                       */
/******************************************/
label_ShadowInitStart:
s_mov_b64 s[sgprSrdD+0:sgprSrdD+0+1], s[sgprAddressD+0:sgprAddressD+0+1] // init SRD base address
s_mov_b32 s[sgprSrdD+2], BufferOOB
s_mov_b32 s[sgprSrdD+3], Srd127_96                 // Set bits 127_96 in post-loop SRD
// Shift num records for gfx125x
s_and_b32 s68, s[sgprSrdD+2], 127
s_lshl_b32 s68, s68, 25
s_and_b32 s[sgprSrdD+1], s[sgprSrdD+1], 33554431
s_or_b32 s[sgprSrdD+1], s[sgprSrdD+1], s68
s_lshr_b32 s[sgprSrdD+2], s[sgprSrdD+2], 7

s_mov_b64 s[sgprSrdC+0:sgprSrdC+0+1], s[sgprAddressC+0:sgprAddressC+0+1] // init SRD base address
s_mov_b32 s[sgprSrdC+2], BufferOOB
s_mov_b32 s[sgprSrdC+3], Srd127_96                 // Set bits 127_96 in post-loop SRD
// Shift num records for gfx125x
s_and_b32 s68, s[sgprSrdC+2], 127
s_lshl_b32 s68, s68, 25
s_and_b32 s[sgprSrdC+1], s[sgprSrdC+1], 33554431
s_or_b32 s[sgprSrdC+1], s[sgprSrdC+1], s68
s_lshr_b32 s[sgprSrdC+2], s[sgprSrdC+2], 7


s_mul_i32 s70, MT1, s[sgprWorkGroup1]              // <- wg1*MT1
s_mul_hi_u32 s69, s70, s[sgprStrideC1J]            // ScaleC s70 by Stride
s_mul_i32 s68, s70, s[sgprStrideC1J]               // ScaleC s70 by Stride
s_lshl_b64 s[68:69], s[68:69], s[sgprGSULog2BpeC]  // scale by bpe
s_add_u32 s[sgprSrdC+0], s[sgprAddressC+0], s68    // add lo to SRD
s_addc_u32 s[sgprSrdC+1], s[sgprAddressC+1], s69   // add hi to SRD
s_mul_hi_u32 s69, s70, s[sgprStrideD1J]            // ScaleD s70 by Stride
s_mul_i32 s68, s70, s[sgprStrideD1J]               // ScaleD s70 by Stride
s_lshl_b64 s[68:69], s[68:69], s[sgprGSULog2BpeD]  // scale by bpe
s_add_u32 s[sgprSrdD+0], s[sgprAddressD+0], s68    // add lo to SRD
s_addc_u32 s[sgprSrdD+1], s[sgprAddressD+1], s69   // add hi to SRD

s_mul_hi_u32 s69, s[sgprWorkGroup2], s[sgprStrideCK] // ScaleC s[sgprWorkGroup2] by Stride
s_mul_i32 s68, s[sgprWorkGroup2], s[sgprStrideCK]  // ScaleC s[sgprWorkGroup2] by Stride
s_lshl_b64 s[68:69], s[68:69], s[sgprGSULog2BpeC]  // scale by bpe
s_add_u32 s[sgprSrdC+0], s[sgprSrdC+0], s68        // add lo to SRD
s_addc_u32 s[sgprSrdC+1], s[sgprSrdC+1], s69       // add hi to SRD
s_mul_hi_u32 s69, s[sgprWorkGroup2], s[sgprStrideDK] // ScaleD s[sgprWorkGroup2] by Stride
s_mul_i32 s68, s[sgprWorkGroup2], s[sgprStrideDK]  // ScaleD s[sgprWorkGroup2] by Stride
s_lshl_b64 s[68:69], s[68:69], s[sgprGSULog2BpeD]  // scale by bpe
s_add_u32 s[sgprSrdD+0], s[sgprSrdD+0], s68        // add lo to SRD
s_addc_u32 s[sgprSrdD+1], s[sgprSrdD+1], s69       // add hi to SRD

s_and_b32 s68, s[sgprGSU], 0x3fff                  // Restore GSU
s_cmp_eq_u32 s68, 1                                // GSU == 1 ?
s_cbranch_scc1 label_GSU_2                         // branch if GSU == 1
// GSU Output Buffer offset: Free0 + (Free1-1)*StrideC1J + (Free2-1)*StrideCK * GSUIdx * bpe%s
s_mul_hi_u32 s69, s[sgprSizesFree+0], s[sgprGSUSumIdx] // Free0
s_mul_i32 s68, s[sgprSizesFree+0], s[sgprGSUSumIdx] // Free0
s_sub_u32 s70, s[sgprSizesFree+1], 1               // Free1
s_mul_i32 s70, s70, s[sgprGSUSumIdx]               // Free1
s_mul_hi_u32 s71, s70, s[sgprStrideC1J]            // Free1
s_mul_i32 s70, s70, s[sgprStrideC1J]               // Free1
s_add_u32 s68, s68, s70                            // Free1
s_addc_u32 s69, s69, s71                           // Free1
s_sub_u32 s70, s[sgprSizesFree+2], 1               // Free2
s_mul_i32 s70, s70, s[sgprGSUSumIdx]               // Free2
s_mul_hi_u32 s71, s70, s[sgprStrideCK]             // Free2
s_mul_i32 s70, s70, s[sgprStrideCK]                // Free2
s_add_u32 s68, s68, s70                            // Free2
s_addc_u32 s69, s69, s71                           // Free2
s_lshl_b64 s[68:69], s[68:69], 2                   // scale by bpe
s_add_u32 s[sgprSrdD+0], s[sgprSrdD+0], s68        // add lo GSU offset to SRD
s_addc_u32 s[sgprSrdD+1], s[sgprSrdD+1], s69       // add hi GSU offset to SRD
label_GSU_2:
.set sgprGSULog2BpeC, UNDEF
.set sgprAddressC, UNDEF

/* initC: remove ValuC vgpr buffer [0...8) from pool */

/* initC: remove acc vgpr buffer [0...0) from pool */

/* initC: remove ValuA/B vgpr buffer [16...50) from pool */
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_mov_b32 v[vgprValuC+0], 0                        // initC
v_mov_b32 v[vgprValuC+1], 0                        // initC
v_mov_b32 v[vgprValuC+2], 0                        // initC
v_mov_b32 v[vgprValuC+3], 0                        // initC
v_mov_b32 v[vgprValuC+4], 0                        // initC
v_mov_b32 v[vgprValuC+5], 0                        // initC
v_mov_b32 v[vgprValuC+6], 0                        // initC
v_mov_b32 v[vgprValuC+7], 0                        // initC
s_cmp_eq_u32 s[sgprLoopCounterL], 0                // at last iteration?

/* after InitC, skip to end of prefetch last iter if numIter==0 */
s_cbranch_scc0 label_NoBranch_T8JHFHKM7BO5OHXW     // Only branch on scc1
s_getpc_b64 s[68:69]                               // addr of next instr
s_add_i32 s70, label_PrefetchGlobalLastIterEnd, 4  // target branch offset
s_add_u32 s68, s68, s70                            // add target branch offset
s_addc_u32 s69, s69, 0                             // add high and carry
s_setpc_b64 s[68:69]                               // branch to label_PrefetchGlobalLastIterEnd
label_NoBranch_T8JHFHKM7BO5OHXW:
s_wait_loadcnt 0                                   // wait for global read
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
ds_store_b128 v[vgprLocalWriteAddrA+0], v[vgprG2LA+0:vgprG2LA+0+3] offset:0 // lwoA_0_0_0_0 = (0*LSCA)*(MT0I+PAD) + (0*LSPA) = 0
ds_store_b128 v[vgprLocalWriteAddrA+0], v[vgprG2LA+4:vgprG2LA+4+3] offset:2304 // lwoA_0_0_1_0 = (0*LSCA)*(MT0I+PAD) + (1*LSPA) = 2304
ds_store_b128 v[vgprLocalWriteAddrB+0], v[vgprG2LB+0:vgprG2LB+0+3] offset:0 // lwoB_0_0_0_0 = (0*LSCB)*(MT1J+PAD) + (0*LSPB) = 0
ds_store_b128 v[vgprLocalWriteAddrB+0], v[vgprG2LB+4:vgprG2LB+4+3] offset:2304 // lwoB_0_0_1_0 = (0*LSCB)*(MT1J+PAD) + (1*LSPB) = 2304
v_xor_b32 v[vgprLocalWriteAddrA], 0x4000, v[vgprLocalWriteAddrA] // swap Red Blk
v_xor_b32 v[vgprLocalWriteAddrB], 0x4000, v[vgprLocalWriteAddrB] // swap Red Blk
s_cmp_eq_u32 s[sgprLoopCounterL], 0x1              // PGR=2 but only 1 loop
s_cbranch_scc1 label_skipPGR2_1                    // PGR=2 but only 1 loop
buffer_load_b128 v[vgprG2LA+0:vgprG2LA+0+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], null offen offset:0 // G -> Reg 0_0_0_0
buffer_load_b128 v[vgprG2LA+4:vgprG2LA+4+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], s[sgprScalarGlobalReadOffsetA+0] offen offset:0 // G -> Reg 0_0_1_0
buffer_load_b128 v[vgprG2LB+0:vgprG2LB+0+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], null offen offset:0 // G -> Reg 0_0_0_0
buffer_load_b128 v[vgprG2LB+4:vgprG2LB+4+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+0] offen offset:0 // G -> Reg 0_0_1_0
s_branch label_skipPGR2_2                          // jump to PGR=2 label
label_skipPGR2_1:
label_skipPGR2_2:
s_barrier_signal -1
s_barrier_wait -1                                  // LW to PLR, sync LDS0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
ds_load_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA+0] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0 sync LDS0
ds_load_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB+0] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0 sync LDS0
label_openLoopL:
s_cmp_eq_u32 s[sgprLoopCounterL], 0x1              // LoopCounterL < EndCounter
s_cbranch_scc1 label_toPGR1                        // PGR=2 but only 1 loop, toPGR1
s_cmp_le_u32 s[sgprLoopCounterL], 0x2              // LoopCounterL < EndCounter
s_cbranch_scc1 label_LoopEndL                      // do not enter LoopL
.align 16
label_LoopBeginL:
s_barrier_signal -1
s_barrier_wait -1                                  // PGR, and wait until LW done to sync LDS1
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
ds_load_b128 v[vgprValuA_X2_I0+0:vgprValuA_X2_I0+0+3], v[vgprLocalReadAddrA+0] offset:32 // L -> Reg lro=8 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=2 iui=0 sync LDS0
ds_load_b128 v[vgprValuB_X2_I0+0:vgprValuB_X2_I0+0+3], v[vgprLocalReadAddrB+0] offset:32 // L -> Reg lro=8 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=2 iui=0 sync LDS0
s_wait_dscnt 2
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X0_I0+0+0+0:vgprValuA_X0_I0+0+0+0+1], v[vgprValuB_X0_I0+0+0+0:vgprValuB_X0_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_cmp_eq_u32 s[sgprLoopCounterL], s[sgprStaggerUIter] // Is this the wrapIter?
s_cselect_b32 s68, s[sgprWrapUA+0], s[sgprGlobalReadIncsA+0] // incLower <- ?
s_cselect_b32 s69, s[sgprWrapUA+1], 0              // incUpper <- ?
s_add_u32 s[sgprSrdA+0], s[sgprSrdA+0], s68        // gra SRD += inc(lower)
s_addc_u32 s[sgprSrdA+1], s[sgprSrdA+1], s69       // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitA+0], s[sgprShadowLimitA+0], s68 // limit -= inc)
s_subb_u32 s[sgprShadowLimitA+1], s[sgprShadowLimitA+1], s69 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitA+1], 0              // are we within 2^32?
s_cselect_b32 s[sgprSrdA+2], s[sgprShadowLimitA+0], BufferLimit // Move shadow to real if we are within 2^32
s_and_b32 s8, s[sgprSrdA+2], 127
s_lshl_b32 s8, s8, 25
s_and_b32 s[sgprSrdA+1], s[sgprSrdA+1], 33554431
s_or_b32 s[sgprSrdA+1], s[sgprSrdA+1], s8
s_lshr_b32 s[sgprSrdA+2], s[sgprSrdA+2], 7
s_cmp_eq_u32 s[sgprLoopCounterL], s[sgprStaggerUIter] // Is this the wrapIter?
s_cselect_b32 s68, s[sgprWrapUB+0], s[sgprGlobalReadIncsB+0] // incLower <- ?
s_cselect_b32 s69, s[sgprWrapUB+1], 0              // incUpper <- ?
s_add_u32 s[sgprSrdB+0], s[sgprSrdB+0], s68        // gra SRD += inc(lower)
ds_load_b128 v[vgprValuA_X4_I0+0:vgprValuA_X4_I0+0+3], v[vgprLocalReadAddrA+0] offset:64 // L -> Reg lro=16 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=4 iui=0 sync LDS0
ds_load_b128 v[vgprValuB_X4_I0+0:vgprValuB_X4_I0+0+3], v[vgprLocalReadAddrB+0] offset:64 // L -> Reg lro=16 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=4 iui=0 sync LDS0
s_addc_u32 s[sgprSrdB+1], s[sgprSrdB+1], s69       // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitB+0], s[sgprShadowLimitB+0], s68 // limit -= inc)
s_subb_u32 s[sgprShadowLimitB+1], s[sgprShadowLimitB+1], s69 // limit -= inc)
ds_load_b128 v[vgprValuA_X6_I0+0:vgprValuA_X6_I0+0+3], v[vgprLocalReadAddrA+0] offset:96 // L -> Reg lro=24 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=6 iui=0 sync LDS0
ds_load_b128 v[vgprValuB_X6_I0+0:vgprValuB_X6_I0+0+3], v[vgprLocalReadAddrB+0] offset:96 // L -> Reg lro=24 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=6 iui=0 sync LDS0
s_cmp_eq_u32 s[sgprShadowLimitB+1], 0              // are we within 2^32?
s_cselect_b32 s[sgprSrdB+2], s[sgprShadowLimitB+0], BufferLimit // Move shadow to real if we are within 2^32
s_and_b32 s8, s[sgprSrdB+2], 127
s_lshl_b32 s8, s8, 25
s_and_b32 s[sgprSrdB+1], s[sgprSrdB+1], 33554431
s_or_b32 s[sgprSrdB+1], s[sgprSrdB+1], s8
s_lshr_b32 s[sgprSrdB+2], s[sgprSrdB+2], 7
s_wait_loadcnt 3
ds_store_b128 v[vgprLocalWriteAddrA+0], v[vgprG2LA+0:vgprG2LA+0+3] offset:0 // lwoA_0_0_0_0 = (0*LSCA)*(MT0I+PAD) + (0*LSPA) = 0
buffer_load_b128 v[vgprG2LA+0:vgprG2LA+0+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], null offen offset:0 // G -> Reg 0_0_0_0
s_wait_loadcnt 3
ds_store_b128 v[vgprLocalWriteAddrA+0], v[vgprG2LA+4:vgprG2LA+4+3] offset:2304 // lwoA_0_0_1_0 = (0*LSCA)*(MT0I+PAD) + (1*LSPA) = 2304
buffer_load_b128 v[vgprG2LA+4:vgprG2LA+4+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], s[sgprScalarGlobalReadOffsetA+0] offen offset:0 // G -> Reg 0_0_1_0
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X0_I0+0+2+0:vgprValuA_X0_I0+0+2+0+1], v[vgprValuB_X0_I0+0+2+0:vgprValuB_X0_I0+0+2+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_wait_loadcnt 3
ds_store_b128 v[vgprLocalWriteAddrB+0], v[vgprG2LB+0:vgprG2LB+0+3] offset:0 // lwoB_0_0_0_0 = (0*LSCB)*(MT1J+PAD) + (0*LSPB) = 0
buffer_load_b128 v[vgprG2LB+0:vgprG2LB+0+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], null offen offset:0 // G -> Reg 0_0_0_0
s_wait_dscnt 7
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X2_I0+0+0+0:vgprValuA_X2_I0+0+0+0+1], v[vgprValuB_X2_I0+0+0+0:vgprValuB_X2_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_wait_loadcnt 3
ds_store_b128 v[vgprLocalWriteAddrB+0], v[vgprG2LB+4:vgprG2LB+4+3] offset:2304 // lwoB_0_0_1_0 = (0*LSCB)*(MT1J+PAD) + (1*LSPB) = 2304
buffer_load_b128 v[vgprG2LB+4:vgprG2LB+4+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+0] offen offset:0 // G -> Reg 0_0_1_0
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X2_I0+0+2+0:vgprValuA_X2_I0+0+2+0+1], v[vgprValuB_X2_I0+0+2+0:vgprValuB_X2_I0+0+2+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
v_xor_b32 v[vgprLocalWriteAddrA], 0x4000, v[vgprLocalWriteAddrA] // swap Red Blk
v_xor_b32 v[vgprLocalWriteAddrB], 0x4000, v[vgprLocalWriteAddrB] // swap Red Blk
v_xor_b32 v[vgprLocalReadAddrA], 0x4000, v[vgprLocalReadAddrA] // swap Red Blk
v_xor_b32 v[vgprLocalReadAddrB], 0x4000, v[vgprLocalReadAddrB] // swap Red Blk
s_wait_dscnt 6
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X4_I0+0+0+0:vgprValuA_X4_I0+0+0+0+1], v[vgprValuB_X4_I0+0+0+0:vgprValuB_X4_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
ds_load_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA+0] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0 sync LDS1
ds_load_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB+0] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0 sync LDS1
s_sub_u32 s[sgprLoopCounterL], s[sgprLoopCounterL], 1 // dec counterL
s_cmp_eq_i32 s[sgprLoopCounterL], 0x2              // counterL==2
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X4_I0+0+2+0:vgprValuA_X4_I0+0+2+0+1], v[vgprValuB_X4_I0+0+2+0:vgprValuB_X4_I0+0+2+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_wait_dscnt 6
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X6_I0+0+0+0:vgprValuA_X6_I0+0+0+0+1], v[vgprValuB_X6_I0+0+0+0:vgprValuB_X6_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X6_I0+0+2+0:vgprValuA_X6_I0+0+2+0+1], v[vgprValuB_X6_I0+0+2+0:vgprValuB_X6_I0+0+2+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_cbranch_scc0 label_LoopBeginL                    // restart LoopL
label_LoopEndL:
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
ds_load_b128 v[vgprValuA_X2_I0+0:vgprValuA_X2_I0+0+3], v[vgprLocalReadAddrA+0] offset:32 // L -> Reg lro=8 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=2 iui=0 sync LDS0
ds_load_b128 v[vgprValuB_X2_I0+0:vgprValuB_X2_I0+0+3], v[vgprLocalReadAddrB+0] offset:32 // L -> Reg lro=8 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=2 iui=0 sync LDS0
s_cmp_eq_u32 s[sgprLoopCounterL], s[sgprStaggerUIter] // Is this the wrapIter?
s_cselect_b32 s68, s[sgprWrapUA+0], s[sgprGlobalReadIncsA+0] // incLower <- ?
s_wait_dscnt 2
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X0_I0+0+0+0:vgprValuA_X0_I0+0+0+0+1], v[vgprValuB_X0_I0+0+0+0:vgprValuB_X0_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_cselect_b32 s69, s[sgprWrapUA+1], 0              // incUpper <- ?
s_add_u32 s[sgprSrdA+0], s[sgprSrdA+0], s68        // gra SRD += inc(lower)
s_addc_u32 s[sgprSrdA+1], s[sgprSrdA+1], s69       // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitA+0], s[sgprShadowLimitA+0], s68 // limit -= inc)
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X0_I0+0+2+0:vgprValuA_X0_I0+0+2+0+1], v[vgprValuB_X0_I0+0+2+0:vgprValuB_X0_I0+0+2+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_subb_u32 s[sgprShadowLimitA+1], s[sgprShadowLimitA+1], s69 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitA+1], 0              // are we within 2^32?
s_cselect_b32 s[sgprSrdA+2], s[sgprShadowLimitA+0], BufferLimit // Move shadow to real if we are within 2^32
s_and_b32 s8, s[sgprSrdA+2], 127
s_wait_dscnt 0
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X2_I0+0+0+0:vgprValuA_X2_I0+0+0+0+1], v[vgprValuB_X2_I0+0+0+0:vgprValuB_X2_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_lshl_b32 s8, s8, 25
s_and_b32 s[sgprSrdA+1], s[sgprSrdA+1], 33554431
s_or_b32 s[sgprSrdA+1], s[sgprSrdA+1], s8
s_lshr_b32 s[sgprSrdA+2], s[sgprSrdA+2], 7
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X2_I0+0+2+0:vgprValuA_X2_I0+0+2+0+1], v[vgprValuB_X2_I0+0+2+0:vgprValuB_X2_I0+0+2+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_cmp_eq_u32 s[sgprLoopCounterL], s[sgprStaggerUIter] // Is this the wrapIter?
s_cselect_b32 s68, s[sgprWrapUB+0], s[sgprGlobalReadIncsB+0] // incLower <- ?
s_cselect_b32 s69, s[sgprWrapUB+1], 0              // incUpper <- ?
s_add_u32 s[sgprSrdB+0], s[sgprSrdB+0], s68        // gra SRD += inc(lower)
ds_load_b128 v[vgprValuA_X4_I0+0:vgprValuA_X4_I0+0+3], v[vgprLocalReadAddrA+0] offset:64 // L -> Reg lro=16 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=4 iui=0 sync LDS0
ds_load_b128 v[vgprValuB_X4_I0+0:vgprValuB_X4_I0+0+3], v[vgprLocalReadAddrB+0] offset:64 // L -> Reg lro=16 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=4 iui=0 sync LDS0
s_wait_dscnt 0
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X4_I0+0+0+0:vgprValuA_X4_I0+0+0+0+1], v[vgprValuB_X4_I0+0+0+0:vgprValuB_X4_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_addc_u32 s[sgprSrdB+1], s[sgprSrdB+1], s69       // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitB+0], s[sgprShadowLimitB+0], s68 // limit -= inc)
s_subb_u32 s[sgprShadowLimitB+1], s[sgprShadowLimitB+1], s69 // limit -= inc)
ds_load_b128 v[vgprValuA_X6_I0+0:vgprValuA_X6_I0+0+3], v[vgprLocalReadAddrA+0] offset:96 // L -> Reg lro=24 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=6 iui=0 sync LDS0
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X4_I0+0+2+0:vgprValuA_X4_I0+0+2+0+1], v[vgprValuB_X4_I0+0+2+0:vgprValuB_X4_I0+0+2+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
ds_load_b128 v[vgprValuB_X6_I0+0:vgprValuB_X6_I0+0+3], v[vgprLocalReadAddrB+0] offset:96 // L -> Reg lro=24 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=6 iui=0 sync LDS0
s_cmp_eq_u32 s[sgprShadowLimitB+1], 0              // are we within 2^32?
s_cselect_b32 s[sgprSrdB+2], s[sgprShadowLimitB+0], BufferLimit // Move shadow to real if we are within 2^32
s_and_b32 s8, s[sgprSrdB+2], 127
s_wait_dscnt 0
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X6_I0+0+0+0:vgprValuA_X6_I0+0+0+0+1], v[vgprValuB_X6_I0+0+0+0:vgprValuB_X6_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_lshl_b32 s8, s8, 25
s_and_b32 s[sgprSrdB+1], s[sgprSrdB+1], 33554431
s_or_b32 s[sgprSrdB+1], s[sgprSrdB+1], s8
s_lshr_b32 s[sgprSrdB+2], s[sgprSrdB+2], 7
s_wait_loadcnt 3
ds_store_b128 v[vgprLocalWriteAddrA+0], v[vgprG2LA+0:vgprG2LA+0+3] offset:0 // lwoA_0_0_0_0 = (0*LSCA)*(MT0I+PAD) + (0*LSPA) = 0
s_wait_loadcnt 2
ds_store_b128 v[vgprLocalWriteAddrA+0], v[vgprG2LA+4:vgprG2LA+4+3] offset:2304 // lwoA_0_0_1_0 = (0*LSCA)*(MT0I+PAD) + (1*LSPA) = 2304
s_wait_loadcnt 1
ds_store_b128 v[vgprLocalWriteAddrB+0], v[vgprG2LB+0:vgprG2LB+0+3] offset:0 // lwoB_0_0_0_0 = (0*LSCB)*(MT1J+PAD) + (0*LSPB) = 0
s_wait_loadcnt 0
ds_store_b128 v[vgprLocalWriteAddrB+0], v[vgprG2LB+4:vgprG2LB+4+3] offset:2304 // lwoB_0_0_1_0 = (0*LSCB)*(MT1J+PAD) + (1*LSPB) = 2304
s_wait_dscnt 0
s_barrier_signal -1
s_barrier_wait -1                                  // noLoadLoop sync LDS0
v_xor_b32 v[vgprLocalWriteAddrA], 0x4000, v[vgprLocalWriteAddrA] // swap Red Blk
v_xor_b32 v[vgprLocalWriteAddrB], 0x4000, v[vgprLocalWriteAddrB] // swap Red Blk
v_xor_b32 v[vgprLocalReadAddrA], 0x4000, v[vgprLocalReadAddrA] // swap Red Blk
v_xor_b32 v[vgprLocalReadAddrB], 0x4000, v[vgprLocalReadAddrB] // swap Red Blk
ds_load_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA+0] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0 sync LDS0
ds_load_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB+0] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0 sync LDS0
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X6_I0+0+2+0:vgprValuA_X6_I0+0+2+0+1], v[vgprValuB_X6_I0+0+2+0:vgprValuB_X6_I0+0+2+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
label_toPGR1:
s_and_b32 s8, s[sgprGSU], 0x3fff                   // Restore GSU
s_cmp_eq_u32 s8, 1                                 // GSU == 1 ?
s_cbranch_scc0 label_GSU_3                         // branch if GSU != 1
s_mov_b32 s8, 0
s_cmp_eq_u32 s[sgprBeta], s8                       // Beta == 0
s_cbranch_scc0 label_OptNLL_End                    // Branch if Beta is not zero
s_cmp_eq_u32 s[sgprAlpha], 1.0                     // Alpha == 1.0 ?
s_cbranch_scc0 label_OptNLL_End                    // branch if alpha != 1
s_and_b32 s68, 31, s[sgprSizeI]                    // s68 = s[sgprSizeI] % 32
s_add_u32 s69, -0x1, s[sgprNumWorkGroups0]
s_cmp_ge_u32 s[sgprWorkGroup0], s69                // wg0 >= nwg0-1 ?
s_cselect_b32 s68, s68, 0                          // set rem
s_mov_b32 s8, 0
s_cmp_gt_u32 s68, s8                               // rem > 0
s_cbranch_scc1 label_OptNLL_End                    // jump if edges required
s_and_b32 s68, 31, s[sgprSizeJ]                    // s68 = s[sgprSizeJ] % 32
s_add_u32 s69, -0x1, s[sgprNumWorkGroups1]
s_cmp_ge_u32 s[sgprWorkGroup1], s69                // wg1 >= nwg1-1
s_cselect_b32 s68, s68, 0                          // set rem
s_mov_b32 s8, 0
s_cmp_gt_u32 s68, s8                               // rem > 0
s_cbranch_scc1 label_OptNLL_End                    // jump if edges required
s_and_b32 s69, 31, s[sgprSizesSum+0]               // s69 = s[sgprSizesSum+0] % 32
s_cmp_eq_u32 s69, 0                                // numIterL == 0
s_cbranch_scc0 label_OptNLL_End                    // skip if tail loop required
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
ds_load_b128 v[vgprValuA_X2_I0+0:vgprValuA_X2_I0+0+3], v[vgprLocalReadAddrA+0] offset:32 // L -> Reg lro=8 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=2 iui=0 sync LDS0
ds_load_b128 v[vgprValuB_X2_I0+0:vgprValuB_X2_I0+0+3], v[vgprLocalReadAddrB+0] offset:32 // L -> Reg lro=8 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=2 iui=0 sync LDS0
ds_load_b128 v[vgprValuA_X4_I0+0:vgprValuA_X4_I0+0+3], v[vgprLocalReadAddrA+0] offset:64 // L -> Reg lro=16 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=4 iui=0 sync LDS0
ds_load_b128 v[vgprValuB_X4_I0+0:vgprValuB_X4_I0+0+3], v[vgprLocalReadAddrB+0] offset:64 // L -> Reg lro=16 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=4 iui=0 sync LDS0
s_wait_dscnt 4
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X0_I0+0+0+0:vgprValuA_X0_I0+0+0+0+1], v[vgprValuB_X0_I0+0+0+0:vgprValuB_X0_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
ds_load_b128 v[vgprValuA_X6_I0+0:vgprValuA_X6_I0+0+3], v[vgprLocalReadAddrA+0] offset:96 // L -> Reg lro=24 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=6 iui=0 sync LDS0
ds_load_b128 v[vgprValuB_X6_I0+0:vgprValuB_X6_I0+0+3], v[vgprLocalReadAddrB+0] offset:96 // L -> Reg lro=24 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=6 iui=0 sync LDS0
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X0_I0+0+2+0:vgprValuA_X0_I0+0+2+0+1], v[vgprValuB_X0_I0+0+2+0:vgprValuB_X0_I0+0+2+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_wait_dscnt 4
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X2_I0+0+0+0:vgprValuA_X2_I0+0+0+0+1], v[vgprValuB_X2_I0+0+0+0:vgprValuB_X2_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X2_I0+0+2+0:vgprValuA_X2_I0+0+2+0+1], v[vgprValuB_X2_I0+0+2+0:vgprValuB_X2_I0+0+2+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_wait_dscnt 2
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X4_I0+0+0+0:vgprValuA_X4_I0+0+0+0+1], v[vgprValuB_X4_I0+0+0+0:vgprValuB_X4_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X4_I0+0+2+0:vgprValuA_X4_I0+0+2+0+1], v[vgprValuB_X4_I0+0+2+0:vgprValuB_X4_I0+0+2+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_wait_dscnt 0
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X6_I0+0+0+0:vgprValuA_X6_I0+0+0+0+1], v[vgprValuB_X6_I0+0+0+0:vgprValuB_X6_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X6_I0+0+2+0:vgprValuA_X6_I0+0+2+0+1], v[vgprValuB_X6_I0+0+2+0:vgprValuB_X6_I0+0+2+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
label_toPGR1end_OptNLL:
label_Summation_End_OptNLL:
.set sgprAddressScaleAlphaVec, 48
.set sgprAddressBias, 50
.set sgprBiasType, 52
.set sgprBiasStride, 53
.set sgpractivationAlpha, 54
.set sgpractivationBeta, 55
.set sgprActivationType, 56
s_cmp_eq_u32 s[sgprArgType], 2                     // ArgType == 2 ?
s_cbranch_scc1 label_LoadExternalEpilogueStruct    // branch if ArgType == 2
s_load_b256 s[48:55], s[sgprKernArgAddress:sgprKernArgAddress+1], 88 // 88
s_load_b32 s56, s[sgprKernArgAddress:sgprKernArgAddress+1], 120 // 120
s_branch label_LoadExternalEpilogueStructEnd
label_LoadExternalEpilogueStruct:
s_load_b128 s[48:51], s[sgprKernArgAddress:sgprKernArgAddress+1], 144 // 144
s_load_b64 s[52:53], s[sgprKernArgAddress:sgprKernArgAddress+1], 160 // 160
s_load_b64 s[54:55], s[sgprKernArgAddress:sgprKernArgAddress+1], 184 // 184
s_load_b32 s56, s[sgprKernArgAddress:sgprKernArgAddress+1], 192 // 192
label_LoadExternalEpilogueStructEnd:
.set sgprSrdScaleAlphaVec, 32
.set sgprSrdBias, 40
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_lshrrev_b32 v12, 5, v[vgprSerial]                // 12 = Serial / 32
v_lshrrev_b32 v13, 1, v12                          // 13 = 12 / 2
v_mul_lo_u32 v9, 0x10, v13                         // wave coordination offset 1
v_and_b32 v13, 15, v[vgprSerial]                   // v13 = v[vgprSerial] % 16
v_add_lshl_u32 v9, v13, v9, 0                      // coordination 1 = vwB *(wave_id1 + tid1)
v_mul_lo_u32 v10, v9, s[sgprStrideC1J]             //  offset 1
v_mul_lo_u32 v11, v9, s[sgprStrideD1J]             //  offset 1
v_and_b32 v13, 1, v12                              // v13 = v12 % 2
v_mul_lo_u32 v13, 0x10, v13                        // wave coordination offset 0
v_and_b32 v8, 31, v[vgprSerial]                    // v8 = v[vgprSerial] % 32
v_lshrrev_b32 v8, 4, v8                            // 8 = 8 / 16
v_lshlrev_b32 v8, 3, v8                            // thread0 * continuous_output
v_add_lshl_u32 v8, v13, v8, 0                      // coordination 0 = vwA *(wave_id0 + tid0)
s_mul_i32 s8, 32, s[sgprWorkGroup0]                // wgp0 * MT0
v_add_nc_u32 v8, s8, v8                            // coord 0 = (tid0/MI_m)*4 + waveG0*MIB_m + MT0*SG0
s_mul_i32 s8, 32, s[sgprWorkGroup1]                // wgp1 * MT1
v_add_nc_u32 v9, s8, v9                            // coord 1 = (tid0%MI_m) + waveG1*MIB_n + MT1*SG1
s_wait_loadcnt 1
s_mov_b64 s[sgprSrdScaleAlphaVec+0:sgprSrdScaleAlphaVec+0+1], s[sgprAddressScaleAlphaVec+0:sgprAddressScaleAlphaVec+0+1] // init SRD base address
s_mov_b32 s[sgprSrdScaleAlphaVec+3], Srd127_96     // Set bits 127_96 in post-loop SRD
s_cmp_eq_u64 s[sgprAddressScaleAlphaVec:sgprAddressScaleAlphaVec+1], 0 // s[AddressScaleAlphaVec] == 0 ?
s_cbranch_scc0 label_ScaleAlphaVecAddrValid        // branch if s[AddressScaleAlphaVec] != 0
s_mov_b32 s[sgprSrdScaleAlphaVec+2], 0
s_branch label_ScaleAlphaVecAddrValid_End
label_ScaleAlphaVecAddrValid:
s_mov_b32 s[sgprSrdScaleAlphaVec+2], s[sgprSizeI]
label_ScaleAlphaVecAddrValid_End:
s_mul_i32 s[sgprSrdScaleAlphaVec+2], 0x4, s[sgprSrdScaleAlphaVec+2] // ScaleAlphaVec scaled by BPE
s_add_u32 s8, s[sgprWorkGroup2], 0x1
s_wait_loadcnt 1
s_mul_i32 s8, s[sgprBiasStride], s8                // stride * (wg+1)
s_cmp_eq_u32 s8, 0                                 // bias stride = 0?
s_cselect_b32 s8, s[sgprSizeI], s8
s_mov_b64 s[sgprSrdBias+0:sgprSrdBias+0+1], s[sgprAddressBias+0:sgprAddressBias+0+1] // init SRD base address
s_mov_b32 s[sgprSrdBias+3], Srd127_96              // Set bits 127_96 in post-loop SRD
s_cmp_eq_u64 s[sgprAddressBias:sgprAddressBias+1], 0 // s[AddressBias] == 0 ?
s_cbranch_scc0 label_BiasAddrValid                 // branch if s[AddressBias] != 0
s_mov_b32 s[sgprSrdBias+2], 0
s_branch label_BiasAddrValid_End
label_BiasAddrValid:
s_mov_b32 s[sgprSrdBias+2], s8
label_BiasAddrValid_End:
s_mul_i32 s8, 32, s[sgprWorkGroup0]                // wgp0 * MT0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_add_nc_u32 v16, s8, v[vgprSerial]                // coord 0 = wgp0 * MT0 + thread offset
s_mul_i32 s[sgprSrdBias+2], 0x4, s[sgprSrdBias+2]  // scaled by BPE
s_and_b32 s8, s[sgprSrdBias+2], 127
s_lshl_b32 s8, s8, 25
s_and_b32 s[sgprSrdBias+1], s[sgprSrdBias+1], 33554431
s_or_b32 s[sgprSrdBias+1], s[sgprSrdBias+1], s8
s_lshr_b32 s[sgprSrdBias+2], s[sgprSrdBias+2], 7
s_wait_loadcnt 1
s_mul_i32 s8, s[sgprBiasStride], s[sgprWorkGroup2] // Stride * WG
v_add_nc_u32 v14, s8, v16                          // coord 0 = wgp0 * MT0 + thread offset + Stride * WG
v_lshlrev_b32 v14, 0x2, v14                        // Global bias address scaled by BPE
v_lshlrev_b32 v15, 0x2, v16                        // Global scaleAlpha address scaled by BPE
s_mul_i32 s8, 32, s[sgprWorkGroup1]                // wgp1 * MT1
v_add_nc_u32 v16, s8, v[vgprSerial]                // coord 1 = wgp1 * MT1 + thread offset
buffer_load_b32 v12, v14, s[sgprSrdBias:sgprSrdBias+3], null offen offset:0 // Load Bias
buffer_load_b32 v13, v15, s[sgprSrdScaleAlphaVec:sgprSrdScaleAlphaVec+3], null offen offset:0 // Load ScaleAlphaVec
v_lshlrev_b32 v16, 0x2, v[vgprSerial]              // Local address scaled by BPE
s_barrier_signal -1
s_barrier_wait -1                                  // wait for all global loads.
s_wait_loadcnt 1
ds_store_b32 v16, v12 offset:0                     // store bias
v_cmp_gt_u32 s[sgprAddressScaleAlphaVec], s[sgprSrdScaleAlphaVec+2], 0 //  == 0 ?
s_wait_loadcnt 0
v_cndmask_b32 v13, 1.0, v13, s[sgprAddressScaleAlphaVec] // 1. mul 1 if 0
ds_store_b32 v16, v13 offset:512                   // store scaleAlpha
.set sgprAddressScaleAlphaVec, UNDEF
.set sgprSrdScaleAlphaVec, UNDEF
s_mov_b32 s8, 3
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 3
s_cbranch_scc1 label_To_Activation_Gelu_VW8        // Branch if true
s_mov_b32 s8, 5
s_wait_loadcnt 0
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 5
s_cbranch_scc1 label_To_Activation_Relu_VW8        // Branch if true
s_mov_b32 s8, 6
s_wait_loadcnt 0
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 6
s_cbranch_scc1 label_To_Activation_Sigmoid_VW8     // Branch if true
s_mov_b32 s8, 11
s_wait_loadcnt 0
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 11
s_cbranch_scc1 label_To_Activation_Silu_VW8        // Branch if true
s_mov_b32 s8, 13
s_wait_loadcnt 0
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 13
s_cbranch_scc1 label_To_Activation_Clamp_VW8       // Branch if true
label_To_Activation_None_VW8:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_None_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd
label_To_Activation_Gelu_VW8:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Gelu_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd
label_To_Activation_Relu_VW8:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Relu_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd
label_To_Activation_Sigmoid_VW8:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Sigmoid_VW8, 4      // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd
label_To_Activation_Silu_VW8:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Silu_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd
label_To_Activation_Clamp_VW8:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Clamp_VW8, 4        // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd
label_ActivationSetPCAddrEnd:
label_GW_B0:
label_GW_B0_FD0:
label_GW_B0_FD0_VW8_Then:
s_mul_i32 s8, 32, s[sgprWorkGroup0]                // wgp0 * MT0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_sub_nc_u32 v23, v8, s8
v_lshlrev_b32 v23, 0x2, v23                        // Bias address scaled by BPE
s_barrier_signal -1
s_barrier_wait -1                                  // LDS write barrier
ds_load_b128 v[32:35], v23 offset:0                // load Bias
ds_load_b128 v[36:39], v23 offset:16               // load Bias
ds_load_b128 v[40:43], v23 offset:512              // load scaleAlpha
ds_load_b128 v[44:47], v23 offset:528              // load scaleAlpha
v_add_lshl_u32 v21, v11, v8, 2                     // optSingleColVgpr scaleToBpe: sharedAddrVgpr <- cinRowPtr + coord0, scaled by BPE. BSHERE:coord0=8, coord0Vgpr=8 (multiple bpe)
v_mov_b32 v[vgprValuC+24], v[vgprValuC+0]          // copy MI out reg to vreg[0]
v_mov_b32 v[vgprValuC+25], v[vgprValuC+1]          // copy MI out reg to vreg[1]
v_mov_b32 v[vgprValuC+26], v[vgprValuC+2]          // copy MI out reg to vreg[2]
v_mov_b32 v[vgprValuC+27], v[vgprValuC+3]          // copy MI out reg to vreg[3]
v_mov_b32 v[vgprValuC+28], v[vgprValuC+4]          // copy MI out reg to vreg[4]
v_mov_b32 v[vgprValuC+29], v[vgprValuC+5]          // copy MI out reg to vreg[5]
v_mov_b32 v[vgprValuC+30], v[vgprValuC+6]          // copy MI out reg to vreg[6]
v_mov_b32 v[vgprValuC+31], v[vgprValuC+7]          // copy MI out reg to vreg[7]
s_wait_dscnt 1
v_pk_mul_f32 v[vgprValuC+24:vgprValuC+24+1], v[40:41], v[vgprValuC+24:vgprValuC+24+1] // *= ScaleAlphaVecVMulPK(40)(0)
v_pk_mul_f32 v[vgprValuC+26:vgprValuC+26+1], v[42:43], v[vgprValuC+26:vgprValuC+26+1] // *= ScaleAlphaVecVMulPK(40)(2)
s_wait_dscnt 0
v_pk_mul_f32 v[vgprValuC+28:vgprValuC+28+1], v[44:45], v[vgprValuC+28:vgprValuC+28+1] // *= ScaleAlphaVecVMulPK(40)(4)
v_pk_mul_f32 v[vgprValuC+30:vgprValuC+30+1], v[46:47], v[vgprValuC+30:vgprValuC+30+1] // *= ScaleAlphaVecVMulPK(40)(6)
v_pk_add_f32 v[12:13], v[32:33], v[vgprValuC+24:vgprValuC+24+1] // C += bias
v_pk_add_f32 v[14:15], v[34:35], v[vgprValuC+26:vgprValuC+26+1] // C += bias
v_pk_add_f32 v[16:17], v[36:37], v[vgprValuC+28:vgprValuC+28+1] // C += bias
v_pk_add_f32 v[18:19], v[38:39], v[vgprValuC+30:vgprValuC+30+1] // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b64 v[24:25], v[12:13]
v_mov_b64 v[26:27], v[14:15]
v_mov_b64 v[28:29], v[16:17]
v_mov_b64 v[30:31], v[18:19]
buffer_store_b128 v[24:27], v21, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
buffer_store_b128 v[28:31], v21, s[sgprSrdD:sgprSrdD+3], null offen offset:16 // store D
s_nop 0                                            // 1 wait state required when next inst writes vgprs held by previous dwordx4 store inst
s_branch label_GW_End                              // jump to end
label_GW_End:
s_endpgm                                           // Kernel End
label_OptNLL_End:
label_GSU_3:
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
ds_load_b128 v[vgprValuA_X2_I0+0:vgprValuA_X2_I0+0+3], v[vgprLocalReadAddrA+0] offset:32 // L -> Reg lro=8 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=2 iui=0 sync LDS0
ds_load_b128 v[vgprValuB_X2_I0+0:vgprValuB_X2_I0+0+3], v[vgprLocalReadAddrB+0] offset:32 // L -> Reg lro=8 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=2 iui=0 sync LDS0
ds_load_b128 v[vgprValuA_X4_I0+0:vgprValuA_X4_I0+0+3], v[vgprLocalReadAddrA+0] offset:64 // L -> Reg lro=16 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=4 iui=0 sync LDS0
ds_load_b128 v[vgprValuB_X4_I0+0:vgprValuB_X4_I0+0+3], v[vgprLocalReadAddrB+0] offset:64 // L -> Reg lro=16 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=4 iui=0 sync LDS0
s_wait_dscnt 4
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X0_I0+0+0+0:vgprValuA_X0_I0+0+0+0+1], v[vgprValuB_X0_I0+0+0+0:vgprValuB_X0_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
ds_load_b128 v[vgprValuA_X6_I0+0:vgprValuA_X6_I0+0+3], v[vgprLocalReadAddrA+0] offset:96 // L -> Reg lro=24 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=6 iui=0 sync LDS0
ds_load_b128 v[vgprValuB_X6_I0+0:vgprValuB_X6_I0+0+3], v[vgprLocalReadAddrB+0] offset:96 // L -> Reg lro=24 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=6 iui=0 sync LDS0
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X0_I0+0+2+0:vgprValuA_X0_I0+0+2+0+1], v[vgprValuB_X0_I0+0+2+0:vgprValuB_X0_I0+0+2+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_wait_dscnt 4
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X2_I0+0+0+0:vgprValuA_X2_I0+0+0+0+1], v[vgprValuB_X2_I0+0+0+0:vgprValuB_X2_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X2_I0+0+2+0:vgprValuA_X2_I0+0+2+0+1], v[vgprValuB_X2_I0+0+2+0:vgprValuB_X2_I0+0+2+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_wait_dscnt 2
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X4_I0+0+0+0:vgprValuA_X4_I0+0+0+0+1], v[vgprValuB_X4_I0+0+0+0:vgprValuB_X4_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X4_I0+0+2+0:vgprValuA_X4_I0+0+2+0+1], v[vgprValuB_X4_I0+0+2+0:vgprValuB_X4_I0+0+2+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
s_wait_dscnt 0
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X6_I0+0+0+0:vgprValuA_X6_I0+0+0+0+1], v[vgprValuB_X6_I0+0+0+0:vgprValuB_X6_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X6_I0+0+2+0:vgprValuA_X6_I0+0+2+0+1], v[vgprValuB_X6_I0+0+2+0:vgprValuB_X6_I0+0+2+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]
label_toPGR1end_OrdNLL:
label_PrefetchGlobalLastIterEnd:

/* Tail: add ValuA/B vgpr buffer [16...50) to pool */

/* Tail: add address/G2L vgpr [50...66) to pool */

/******************************************/
/* Tail Loop                              */
/******************************************/

/* local write reset offsets a */
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_and_b32 v[vgprLocalWriteAddrA], 0xf03fff, v[vgprLocalWriteAddrA] // reset to Red

/* local write reset offsets b */
v_and_b32 v[vgprLocalWriteAddrB], 0xf03fff, v[vgprLocalWriteAddrB] // reset to Red
/* Check out VGPR (numG2LA,numG2LB,numG2LMetadata) = (8,8,0) */
.set vgprG2LA_BASE, 16
.set vgprG2LA, vgprG2LA_BASE+0
.set vgprG2LB_BASE, 24
.set vgprG2LB, vgprG2LB_BASE+0

/* remove stagger offsets for tail loop */
s_cmp_eq_u32 s[sgprOrigLoopCounter], 0             // skip if main loop was not executed
s_cbranch_scc1 label_SkipRemoveStagger             // skip removeStagger
//  removeStagger A
s_sub_i32 s68, 3, s[sgprStaggerUIter]
s_cmp_ge_i32 s68, 0
s_cbranch_scc0 label_Negative_S4FDBQ587JJL6NOU
s_mul_hi_u32 s69, s68, s[sgprGlobalReadIncsA+0]    // start offset S in bytes
s_mul_i32 s68, s68, s[sgprGlobalReadIncsA+0]       // start offset S in bytes
s_branch label_MultiplyDone_L43KTIIJOOEN7J6P
label_Negative_S4FDBQ587JJL6NOU:
s_abs_i32 s68, s68
s_mul_hi_u32 s69, s68, s[sgprGlobalReadIncsA+0]    // start offset S in bytes
s_mul_i32 s68, s68, s[sgprGlobalReadIncsA+0]       // start offset S in bytes
s_xor_b32 s68, s68, 0xffffffff
s_xor_b32 s69, s69, 0xffffffff
s_add_u32 s68, s68, 0x1
s_addc_u32 s69, s69, 0
label_MultiplyDone_L43KTIIJOOEN7J6P:
s_sub_u64 s[68:69], s[68:69], s[sgprWrapUA:sgprWrapUA+1] // S - WrapU
s_add_u32 s[sgprSrdA+0], s[sgprSrdA+0], s68        // gra SRD += inc(lower)
s_addc_u32 s[sgprSrdA+1], s[sgprSrdA+1], s69       // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitA+0], s[sgprShadowLimitA+0], s68 // limit -= inc)
s_subb_u32 s[sgprShadowLimitA+1], s[sgprShadowLimitA+1], s69 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitA+1], 0              // are we within 2^32?
s_cselect_b32 s[sgprSrdA+2], s[sgprShadowLimitA+0], BufferLimit // Move shadow to real if we are within 2^32
// Shift num records for gfx125x
s_and_b32 s8, s[sgprSrdA+2], 127
s_lshl_b32 s8, s8, 25
s_and_b32 s[sgprSrdA+1], s[sgprSrdA+1], 33554431
s_or_b32 s[sgprSrdA+1], s[sgprSrdA+1], s8
s_lshr_b32 s[sgprSrdA+2], s[sgprSrdA+2], 7
//  removeStagger B
s_sub_i32 s68, 3, s[sgprStaggerUIter]
s_cmp_ge_i32 s68, 0
s_cbranch_scc0 label_Negative_UR8VN3A1SJCPC6PO
s_mul_hi_u32 s69, s68, s[sgprGlobalReadIncsB+0]    // start offset S in bytes
s_mul_i32 s68, s68, s[sgprGlobalReadIncsB+0]       // start offset S in bytes
s_branch label_MultiplyDone_HYY06MPL0TYYIAT2
label_Negative_UR8VN3A1SJCPC6PO:
s_abs_i32 s68, s68
s_mul_hi_u32 s69, s68, s[sgprGlobalReadIncsB+0]    // start offset S in bytes
s_mul_i32 s68, s68, s[sgprGlobalReadIncsB+0]       // start offset S in bytes
s_xor_b32 s68, s68, 0xffffffff
s_xor_b32 s69, s69, 0xffffffff
s_add_u32 s68, s68, 0x1
s_addc_u32 s69, s69, 0
label_MultiplyDone_HYY06MPL0TYYIAT2:
s_sub_u64 s[68:69], s[68:69], s[sgprWrapUB:sgprWrapUB+1] // S - WrapU
s_add_u32 s[sgprSrdB+0], s[sgprSrdB+0], s68        // gra SRD += inc(lower)
s_addc_u32 s[sgprSrdB+1], s[sgprSrdB+1], s69       // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitB+0], s[sgprShadowLimitB+0], s68 // limit -= inc)
s_subb_u32 s[sgprShadowLimitB+1], s[sgprShadowLimitB+1], s69 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitB+1], 0              // are we within 2^32?
s_cselect_b32 s[sgprSrdB+2], s[sgprShadowLimitB+0], BufferLimit // Move shadow to real if we are within 2^32
// Shift num records for gfx125x
s_and_b32 s8, s[sgprSrdB+2], 127
s_lshl_b32 s8, s8, 25
s_and_b32 s[sgprSrdB+1], s[sgprSrdB+1], 33554431
s_or_b32 s[sgprSrdB+1], s[sgprSrdB+1], s8
s_lshr_b32 s[sgprSrdB+2], s[sgprSrdB+2], 7
label_SkipRemoveStagger:

// numIterL = LOCAL_SPLITU * min(sizeL % LOCAL_DEPTHU, DEPTHU / LOCAL_SPLITU)
s_and_b32 s[sgprLoopCounterL], 31, s[sgprSizesSum+0] // s[sgprLoopCounterL] = s[sgprSizesSum+0] % 32
s_and_b32 s68, s[sgprGSU], 0x8000                  // SCC = (GSUC == 1) ?
s_cbranch_scc1 label_GSUC_TL                       // branch if GSUC == 1
s_cmp_lg_u32 s[sgprGSUSumIdx], s[sgprGSUSumIdx+1]  // gsuSumIdx == numIterPerWgRemainder
s_cmov_b32 s[sgprLoopCounterL], 0                  // numIter=0 if gsuSimIdx != numIterPerWgRemainder
s_branch label_GSUC_TL_End
label_GSUC_TL:
s_lshr_b32 s69, s[sgprSizesSum], 5                 // s69 = s[sgprSizesSum] / 32
s_and_b32 s70, s[sgprGSU], 0x3fff                  // Restore GSU
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_cvt_f32_u32 v32, s70                             // s68 = s69 / s70
v_rcp_iflag_f32 v32, v32                           // s68 = s69 / s70
v_cvt_f32_u32 v33, s69                             // s68 = s69 / s70
v_mul_f32 v32, v32, v33                            // s68 = s69 / s70
v_cvt_u32_f32 v32, v32                             // s68 = s69 / s70
v_mul_u32_u24 v33, v32, s70                        // s68 = s69 / s70
v_sub_nc_u32 v33, s69, v33                         // s68 = s69 / s70
v_cmp_eq_u32 vcc_lo, v33, s70                      // s68 = s69 / s70
s_mov_b32 exec_lo, vcc_lo                          // s68 = s69 / s70
v_add_nc_u32 v32, 1, v32                           // s68 = s69 / s70
v_mov_b32 v33, 0                                   // s[sgprGSUSumIdx+1] = s69 % s70
s_mov_b32 exec_lo, -1                              // Reset exec
v_cmp_gt_u32 vcc_lo, v33, s70                      // overflow happened in remainder
s_mov_b32 exec_lo, vcc_lo                          // overflow happened in remainder
v_sub_nc_u32 v32, v32, 1                           // quotient - 1
v_mul_u32_u24 v33, v32, s70                        // re-calculate remainder
v_sub_nc_u32 v33, s69, v33                         // re-calculate remainder
s_mov_b32 exec_lo, -1                              // Reset exec
v_readfirstlane_b32 s68, v32                       // quotient
v_readfirstlane_b32 s[sgprGSUSumIdx+1], v33        // remainder
s_sub_u32 s69, s70, 1                              // GSU-1
s_cmp_eq_u32 s68, 0                                // quotient == 0
s_cselect_b32 s68, s[sgprGSUSumIdx+1], s69         // lastWg = (quotient==0) ? numIterPerWgRemainder : GSU-1
s_cmp_lg_u32 s[sgprGSUSumIdx], s68                 // gsuSumIdx == lastWg
s_cmov_b32 s[sgprLoopCounterL], 0                  // numIter=0 if gsuSumIdx != lastWg
label_GSUC_TL_End:
s_cmp_eq_u32 s[sgprLoopCounterL], 0                // numIterL == 0
s_mov_b32 s[sgprOrigLoopCounter], 0                // repurpose to count each localRead increment
s_cbranch_scc1 label_SkipTailLoopL                 // skip to end of tail loop b/c numIter==0

/* Update M0 for DTLDS */

/* Tail global read A */
/* g2l=0, load component 0 */
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
buffer_load_b32 v[vgprG2LA+0+0], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], null offen offset:0 // load one buffer value
/* g2l=0, load component 1 */
buffer_load_b32 v[vgprG2LA+0+1], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], null offen offset:4 // load one buffer value
/* g2l=0, load component 2 */
buffer_load_b32 v[vgprG2LA+0+2], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], null offen offset:8 // load one buffer value
/* g2l=0, load component 3 */
buffer_load_b32 v[vgprG2LA+0+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], null offen offset:12 // load one buffer value
/* g2l=4, load component 0 */
buffer_load_b32 v[vgprG2LA+4+0], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], s[sgprScalarGlobalReadOffsetA+0] offen offset:0 // load one buffer value
/* g2l=4, load component 1 */
buffer_load_b32 v[vgprG2LA+4+1], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], s[sgprScalarGlobalReadOffsetA+0] offen offset:4 // load one buffer value
/* g2l=4, load component 2 */
buffer_load_b32 v[vgprG2LA+4+2], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], s[sgprScalarGlobalReadOffsetA+0] offen offset:8 // load one buffer value
/* g2l=4, load component 3 */
buffer_load_b32 v[vgprG2LA+4+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], s[sgprScalarGlobalReadOffsetA+0] offen offset:12 // load one buffer value

/* Update M0 for DTLDS */

/* Tail global read B */
/* g2l=0, load component 0 */
buffer_load_b32 v[vgprG2LB+0+0], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], null offen offset:0 // load one buffer value
/* g2l=0, load component 1 */
buffer_load_b32 v[vgprG2LB+0+1], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], null offen offset:4 // load one buffer value
/* g2l=0, load component 2 */
buffer_load_b32 v[vgprG2LB+0+2], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], null offen offset:8 // load one buffer value
/* g2l=0, load component 3 */
buffer_load_b32 v[vgprG2LB+0+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], null offen offset:12 // load one buffer value
/* g2l=4, load component 0 */
buffer_load_b32 v[vgprG2LB+4+0], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+0] offen offset:0 // load one buffer value
/* g2l=4, load component 1 */
buffer_load_b32 v[vgprG2LB+4+1], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+0] offen offset:4 // load one buffer value
/* g2l=4, load component 2 */
buffer_load_b32 v[vgprG2LB+4+2], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+0] offen offset:8 // load one buffer value
/* g2l=4, load component 3 */
buffer_load_b32 v[vgprG2LB+4+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+0] offen offset:12 // load one buffer value
s_wait_loadcnt 0                                   // 2wait for global read
// Skip force waitcnt0
s_barrier_signal -1
s_barrier_wait -1

/* local write a */
ds_store_b128 v[vgprLocalWriteAddrA+0], v[vgprG2LA+0:vgprG2LA+0+3] offset:0 // lwoA_0_0_0_0 = (0*LSCA)*(MT0I+PAD) + (0*LSPA) = 0
ds_store_b128 v[vgprLocalWriteAddrA+0], v[vgprG2LA+4:vgprG2LA+4+3] offset:2304 // lwoA_0_0_1_0 = (0*LSCA)*(MT0I+PAD) + (1*LSPA) = 2304

/* local write b */
ds_store_b128 v[vgprLocalWriteAddrB+0], v[vgprG2LB+0:vgprG2LB+0+3] offset:0 // lwoB_0_0_0_0 = (0*LSCB)*(MT1J+PAD) + (0*LSPB) = 0
ds_store_b128 v[vgprLocalWriteAddrB+0], v[vgprG2LB+4:vgprG2LB+4+3] offset:2304 // lwoB_0_0_1_0 = (0*LSCB)*(MT1J+PAD) + (1*LSPB) = 2304

/* Recalc local read offsets */
/* lr0I */
v_and_b32 v33, 31, v[vgprSerial]                   // 0. thread id in wave: wtid = tid % wavelength(32)
v_and_b32 v32, 15, v33                             // 1. N offset: nIdx = wtid % MI_N(16)
v_lshlrev_b32 v32, 5, v32                          // 1. N offset: nOffset = nIdx * nStride(32)
/* Skip. 2. block offset: bnOffset = 0 when num1DBlocks = 1 */
                                                   // 4. apply VectorWidth: bnOffset = bnOffset * vw(1) (multiplier is 1, do nothing)
v_lshrrev_b32 v33, 4, v33                          // 5. K offset: kIdx = wtid / (MIN(16) * MIBB(1))
v_lshl_add_u32 v32, v33, 1, v32                    // 5. K offset: lrKOffset = kIdx * mStride(2); 6. offset in wave: lrOffset = bnOffset + lrKOffset
v_lshrrev_b32 v36, 5, v[vgprSerial]                // 7. wave offset in N dimen: wtid = tid / dividedForWaveId(32)
v_and_b32 v36, 1, v36                              // 7. wave offset in M dimen: wtid0 = wtid / num1DWaves(2)
v_lshl_add_u32 v32, v36, 9, v32                    // 7. wave offset in M dimen: wOffset = wtid0 * W0Stride(512); 7. final local read offset: flrOffset = lrOffset + WOffset
/* lr1J */
v_and_b32 v34, 31, v[vgprSerial]                   // 0. thread id in wave: wtid = tid % wavelength(32)
v_and_b32 v33, 15, v34                             // 1. N offset: nIdx = wtid % MI_N(16)
v_lshlrev_b32 v33, 5, v33                          // 1. N offset: nOffset = nIdx * nStride(32)
/* Skip. 2. block offset: bnOffset = 0 when num1DBlocks = 1 */
                                                   // 4. apply VectorWidth: bnOffset = bnOffset * vw(1) (multiplier is 1, do nothing)
v_lshrrev_b32 v34, 4, v34                          // 5. K offset: kIdx = wtid / (MIN(16) * MIBB(1))
v_lshl_add_u32 v33, v34, 1, v33                    // 5. K offset: lrKOffset = kIdx * mStride(2); 6. offset in wave: lrOffset = bnOffset + lrKOffset
v_lshrrev_b32 v35, 6, v[vgprSerial]                // 7. wave offset in N dimen: wtid = tid / dividedForWaveId(64)
v_and_b32 v35, 1, v35                              // 7. wave offset in M dimen: wtid0 = wtid / num1DWaves(2)
v_lshl_add_u32 v33, v35, 9, v33                    // 7. wave offset in M dimen: wOffset = wtid0 * W0Stride(512); 7. final local read offset: flrOffset = lrOffset + WOffset
v_lshrrev_b32 v34, 5, v[vgprSerial]                // 34 = Serial / 32
v_lshrrev_b32 v34, 2, v34                          // LSU offset: Get LSU wave_id
s_mov_b32 s8, 32                                   // LSU offset: stride = lsuStride(32) when umlds==True
v_mul_lo_u32 v34, s8, v34                          // LSU offset: lsuoffset = wave_id*lsuStride*(MT0+PAD)
v_add_nc_u32 v[vgprLocalReadAddrA], v34, v32       // Final Offset: offset = (lro0+lsuoffset)*bpeDS
v_lshlrev_b32 v[vgprLocalReadAddrA], 2, v[vgprLocalReadAddrA] //  (multiple bpe)
v_lshrrev_b32 v35, 8, v[vgprLocalReadAddrA]        // Final Offset: padding 32 per block 256
v_lshl_add_u32 v[vgprLocalReadAddrA], v35, 5, v[vgprLocalReadAddrA] // Final Offset: padding 32 per block 256
v_lshrrev_b32 v32, 5, v[vgprSerial]                // 32 = Serial / 32
v_lshrrev_b32 v32, 2, v32                          // LSU offset: Get LSU wave_id
                                                   // LSU offset: stride = lsuStride(32) when umlds==True (dup assign opt.)
v_mul_lo_u32 v32, s8, v32                          // LSU offset: lsuoffset = wave_id*lsuStride*(MT1+PAD)
v_add_nc_u32 v[vgprLocalReadAddrB], v32, v33       // Final Offset: offset = (lro1+lsuoffset)*bpeDS
v_lshlrev_b32 v[vgprLocalReadAddrB], 2, v[vgprLocalReadAddrB] //  (multiple bpe)
v_lshrrev_b32 v34, 8, v[vgprLocalReadAddrB]        // Final Offset: padding 32 per block 256
v_lshl_add_u32 v[vgprLocalReadAddrB], v34, 5, v[vgprLocalReadAddrB] // Final Offset: padding 32 per block 256
v_add_co_u32 v[vgprLocalReadAddrB+0], vcc_lo, 0x1200, v[vgprLocalReadAddrB+0] //  += LdsOffsetB (lower)
s_wait_dscnt 0                                     // 5wait for local write
// Skip force waitcnt0
s_barrier_signal -1
s_barrier_wait -1                                  // Tail loop LW->LR, sync LDS0
.set vgprG2LA_BASE, UNDEF
.set vgprG2LA, UNDEF
.set vgprG2LB_BASE, UNDEF
.set vgprG2LB, UNDEF
.set vgprValuA_X0_I0_BASE, 16
.set vgprValuA_X0_I0, vgprValuA_X0_I0_BASE+0
.set vgprValuA_X1_I0, vgprValuA_X0_I0_BASE+2
.set vgprValuA_X2_I0, vgprValuA_X0_I0_BASE+4
.set vgprValuA_X3_I0, vgprValuA_X0_I0_BASE+6
.set vgprValuA_X4_I0, vgprValuA_X0_I0_BASE+8
.set vgprValuA_X5_I0, vgprValuA_X0_I0_BASE+10
.set vgprValuA_X6_I0, vgprValuA_X0_I0_BASE+12
.set vgprValuA_X7_I0, vgprValuA_X0_I0_BASE+14
.set vgprValuB_X0_I0_BASE, 32
.set vgprValuB_X0_I0, vgprValuB_X0_I0_BASE+0
.set vgprValuB_X1_I0, vgprValuB_X0_I0_BASE+2
.set vgprValuB_X2_I0, vgprValuB_X0_I0_BASE+4
.set vgprValuB_X3_I0, vgprValuB_X0_I0_BASE+6
.set vgprValuB_X4_I0, vgprValuB_X0_I0_BASE+8
.set vgprValuB_X5_I0, vgprValuB_X0_I0_BASE+10
.set vgprValuB_X6_I0, vgprValuB_X0_I0_BASE+12
.set vgprValuB_X7_I0, vgprValuB_X0_I0_BASE+14

/* Tail: local read reset offsets a */

/* localReadResetOffsets */
/* handled internally */
v_and_b32 v[vgprLocalReadAddrA+0], 0x3fff, v[vgprLocalReadAddrA+0] // reset Red,Blk -> Red

/* Tail: local read reset offsets b */

/* localReadResetOffsets */
/* handled internally */
v_and_b32 v[vgprLocalReadAddrB+0], 0x3fff, v[vgprLocalReadAddrB+0] // reset Red,Blk -> Red

/* Tail: local read init pointers a */

/* localReadInitPointers */

/* Tail: local read init pointers b */

/* localReadInitPointers */

/* tail loop: macs */
.align 16
label_TailLoopBeginL:

/* local read a */
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
ds_load_b64 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+1], v[vgprLocalReadAddrA+0] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0 sync LDS0

/* local read b */
ds_load_b64 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+1], v[vgprLocalReadAddrB+0] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=32 vIdx=0 eIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0 sync LDS0

/* local read inc a */
s_mov_b32 s8, 16                                   // inc
v_add_co_u32 v[vgprLocalReadAddrA+0], vcc_lo, s8, v[vgprLocalReadAddrA+0] // lrA += 16 (bpeDS)

/* local read inc b */
                                                   // inc (dup assign opt.)
v_add_co_u32 v[vgprLocalReadAddrB+0], vcc_lo, s8, v[vgprLocalReadAddrB+0] // lrB += 16 (bpeDS)
s_wait_dscnt 0                                     // 4wait for local read
v_and_b32 v48, 31, v[vgprSerial]                   // v48 = v[vgprSerial] % 32
v_lshrrev_b32 v48, 4, v48                          // 48 = 48 / 16
v_lshlrev_b32 v48, 1, v48                          // v48 = v48 * 2
v_cmp_ge_i32 s68, v48, s[sgprLoopCounterL]         // check K index >= Size L
v_cndmask_b32 v[vgprValuA_X0_I0+0+0+0+0], v[vgprValuA_X0_I0+0+0+0+0], 0, s68 // set 0 if K_idx >= sizeL
v_cndmask_b32 v[vgprValuA_X0_I0+0+0+0+1], v[vgprValuA_X0_I0+0+0+0+1], 0, s68 // set 0 if K_idx >= sizeL
v_cndmask_b32 v[vgprValuB_X0_I0+0+0+0+0], v[vgprValuB_X0_I0+0+0+0+0], 0, s68 // set 0 if K_idx >= sizeL
v_cndmask_b32 v[vgprValuB_X0_I0+0+0+0+1], v[vgprValuB_X0_I0+0+0+0+1], 0, s68 // set 0 if K_idx >= sizeL
s_and_b32 s70, s[sgprLoopCounterL], 1              // get inputs for edge thread
s_sub_u32 s70, 2, s70                              // use shift to fill 0 for outside element
s_lshl_b32 s70, s70, 5                             // use shift to fill 0 for outside element
v_lshlrev_b64 v[50:51], s70, v[vgprValuA_X0_I0+0+0+0+0:vgprValuA_X0_I0+0+0+0+0+1]
v_add_nc_u32 v49, v48, 2                           // add part of K: 64 bit groupd
v_cmp_ge_i32 s68, v49, s[sgprLoopCounterL]         // check K index >= Size L
v_cndmask_b32 v[vgprValuA_X0_I0+0+0+0+0], v[vgprValuA_X0_I0+0+0+0+0], v50, s68
v_cmp_ge_i32 s68, v49, s[sgprLoopCounterL]         // check K index >= Size L
v_cndmask_b32 v[vgprValuA_X0_I0+0+0+0+1], v[vgprValuA_X0_I0+0+0+0+1], v51, s68
v_lshlrev_b64 v[50:51], s70, v[vgprValuB_X0_I0+0+0+0+0:vgprValuB_X0_I0+0+0+0+0+1]
v_add_nc_u32 v49, v48, 2                           // add part of K: 64 bits group
v_cmp_ge_i32 s68, v49, s[sgprLoopCounterL]         // check K index >= Size L
v_cndmask_b32 v[vgprValuB_X0_I0+0+0+0+0], v[vgprValuB_X0_I0+0+0+0+0], v50, s68
v_cmp_ge_i32 s68, v49, s[sgprLoopCounterL]         // check K index >= Size L
v_cndmask_b32 v[vgprValuB_X0_I0+0+0+0+1], v[vgprValuB_X0_I0+0+0+0+1], v51, s68
label_TailLoop_SkipZeroOutMask_8S4L1KCK9VFC7AQU:
s_nop 1
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_wmma_f32_16x16x4_f32 v[vgprValuC+0:vgprValuC+0+7], v[vgprValuA_X0_I0+0+0+0:vgprValuA_X0_I0+0+0+0+1], v[vgprValuB_X0_I0+0+0+0:vgprValuB_X0_I0+0+0+0+1], v[vgprValuC+0:vgprValuC+0+7] // left value = v[0+0:7+0]

/* closeLoop loopL finalLoop=1 tailLoop=1 */
s_sub_i32 s[sgprLoopCounterL], s[sgprLoopCounterL], 0x4 // dec counterL (tailLoop)
s_add_u32 s[sgprOrigLoopCounter], s[sgprOrigLoopCounter], 0x4 // inc counterL
s_cmp_le_i32 s[sgprLoopCounterL], 0x0              // counterL<=0
s_cbranch_scc0 label_TailLoopBeginL                // restart LoopL
label_TailLoopEndL:
label_SkipTailLoopL:
.set vgprValuA_X0_I0_BASE, UNDEF
.set vgprValuA_X0_I0, UNDEF
.set vgprValuA_X1_I0, UNDEF
.set vgprValuA_X2_I0, UNDEF
.set vgprValuA_X3_I0, UNDEF
.set vgprValuA_X4_I0, UNDEF
.set vgprValuA_X5_I0, UNDEF
.set vgprValuA_X6_I0, UNDEF
.set vgprValuA_X7_I0, UNDEF
.set vgprValuB_X0_I0_BASE, UNDEF
.set vgprValuB_X0_I0, UNDEF
.set vgprValuB_X1_I0, UNDEF
.set vgprValuB_X2_I0, UNDEF
.set vgprValuB_X3_I0, UNDEF
.set vgprValuB_X4_I0, UNDEF
.set vgprValuB_X5_I0, UNDEF
.set vgprValuB_X6_I0, UNDEF
.set vgprValuB_X7_I0, UNDEF

/* Tail: add MISC Vgpr [8...16) to pool */
label_Summation_End_ZU0B7F2XE71N7LVL:
.set sgprWGM, UNDEF
.set sgprLoopCounterL, UNDEF
.set sgprOrigLoopCounter, UNDEF
.set sgprAddressA, UNDEF
.set sgprAddressB, UNDEF
.set sgprStridesA, UNDEF
.set sgprStridesB, UNDEF
.set sgprStaggerUIter, UNDEF
.set sgprSrdA, UNDEF
.set sgprSrdB, UNDEF
.set sgprShadowLimitA, UNDEF
.set sgprShadowLimitB, UNDEF
.set sgprWrapUA, UNDEF
.set sgprWrapUB, UNDEF
.set sgprGlobalReadIncsA, UNDEF
.set sgprGlobalReadIncsB, UNDEF
.set sgprScalarGlobalReadOffsetA, UNDEF
.set sgprScalarGlobalReadOffsetB, UNDEF
/* load store sgprs */
.set sgprAddressScaleAlphaVec, 48
.set sgprAddressBias, 50
.set sgprBiasType, 52
.set sgprBiasStride, 53
.set sgpractivationAlpha, 54
.set sgpractivationBeta, 55
.set sgprActivationType, 56
s_and_b32 s8, s[sgprGSU], 0x3fff                   // Restore GSU
s_cmp_eq_u32 s8, 1                                 // GSU == 1 ?
s_cbranch_scc0 label_GSU_4                         // branch if GSU != 1
/* Check if custom structure pointer is null */
s_cmp_eq_u32 s[sgprArgType], 2                     // ArgType == 2 ?
s_cbranch_scc1 label_LoadExternalEpilogueStruct_1  // branch if ArgType == 2
s_load_b256 s[48:55], s[sgprKernArgAddress:sgprKernArgAddress+1], 88 // 88
s_load_b32 s56, s[sgprKernArgAddress:sgprKernArgAddress+1], 120 // 120
s_branch label_LoadExternalEpilogueStructEnd_1
label_LoadExternalEpilogueStruct_1:
s_load_b128 s[48:51], s[sgprKernArgAddress:sgprKernArgAddress+1], 144 // 144
s_load_b64 s[52:53], s[sgprKernArgAddress:sgprKernArgAddress+1], 160 // 160
s_load_b64 s[54:55], s[sgprKernArgAddress:sgprKernArgAddress+1], 184 // 184
s_load_b32 s56, s[sgprKernArgAddress:sgprKernArgAddress+1], 192 // 192
label_LoadExternalEpilogueStructEnd_1:
label_GSU_4:
.set sgprSrdScaleAlphaVec, 32
.set sgprSrdBias, 40

/* Mapping of Acc register -> C Vgpr register */

/* Multiply MI out register with Alpha -> C Vgpr register */

/* not-LocalSplitU: global write indices */
/* computeStoreVgprs */
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_lshrrev_b32 v12, 5, v[vgprSerial]                // 12 = Serial / 32
v_lshrrev_b32 v13, 1, v12                          // 13 = 12 / 2
v_mul_lo_u32 v9, 0x10, v13                         // wave coordination offset 1
v_and_b32 v13, 15, v[vgprSerial]                   // v13 = v[vgprSerial] % 16
v_add_lshl_u32 v9, v13, v9, 0                      // coordination 1 = vwB *(wave_id1 + tid1)
v_mul_lo_u32 v10, v9, s[sgprStrideC1J]             //  offset 1
v_mul_lo_u32 v11, v9, s[sgprStrideD1J]             //  offset 1
v_and_b32 v13, 1, v12                              // v13 = v12 % 2
v_mul_lo_u32 v13, 0x10, v13                        // wave coordination offset 0
v_and_b32 v8, 31, v[vgprSerial]                    // v8 = v[vgprSerial] % 32
v_lshrrev_b32 v8, 4, v8                            // 8 = 8 / 16
v_lshlrev_b32 v8, 3, v8                            // thread0 * continuous_output
v_add_lshl_u32 v8, v13, v8, 0                      // coordination 0 = vwA *(wave_id0 + tid0)
s_mul_i32 s8, 32, s[sgprWorkGroup0]                // wgp0 * MT0
v_add_nc_u32 v8, s8, v8                            // coord 0 = (tid0/MI_m)*4 + waveG0*MIB_m + MT0*SG0
s_mul_i32 s8, 32, s[sgprWorkGroup1]                // wgp1 * MT1
v_add_nc_u32 v9, s8, v9                            // coord 1 = (tid0%MI_m) + waveG1*MIB_n + MT1*SG1

/* not-LocalSplitU: global write */

/******************************************/
/* Global Write Elements                  */
/******************************************/
s_wait_kmcnt 0                                     // wait for 36 bytes of kern args.
s_and_b32 s8, s[sgprGSU], 0x3fff                   // Restore GSU
s_cmp_eq_u32 s8, 1                                 // GSU == 1 ?
s_cbranch_scc1 label_GSU_5                         // branch if GSU == 1
.set sgprAddressScaleAlphaVec, UNDEF
.set sgprSrdScaleAlphaVec, UNDEF
label_GW_B0_1:
label_GW_B0_FD0_1:
s_and_b32 s30, 31, s[sgprSizeI]                    // s30 = s[sgprSizeI] % 32
s_add_u32 s31, -0x1, s[sgprNumWorkGroups0]
s_cmp_ge_u32 s[sgprWorkGroup0], s31                // wg0 >= nwg0-1 ?
s_cselect_b32 s30, s30, 0                          // set rem
s_mov_b32 s8, 0
s_cmp_gt_u32 s30, s8                               // rem > 0
s_cbranch_scc1 label_GW_B0_FD0_VW8_Else_1          // jump if edges required
s_and_b32 s30, 31, s[sgprSizeJ]                    // s30 = s[sgprSizeJ] % 32
s_add_u32 s31, -0x1, s[sgprNumWorkGroups1]
s_cmp_ge_u32 s[sgprWorkGroup1], s31                // wg1 >= nwg1-1
s_cselect_b32 s30, s30, 0                          // set rem
s_mov_b32 s8, 0
s_cmp_gt_u32 s30, s8                               // rem > 0
s_cbranch_scc1 label_GW_B0_FD0_VW8_Then_1          // jump if edges required
label_GW_B0_FD0_VW8_NonEdge_1:

/* edge=0, allocate 1 sgpr. perBatchTmpS=1 perBatchMaskS=0 perElementMaskS=0 elementsPerBatch=21 */
/* optSingleColVgpr=1 optSharedColVgpr=0 optSGPRUsage=BufferLoad_Mask optSrdIncForRow=1 factorDim=0 */

/******************************************/
/* Global Write Batch #0 (d1,d0,vc1,vc0) = */
/*    (0,0,0,0:vw8)                       */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,0,0) */
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_add_lshl_u32 v15, v11, v8, 2                     // optSingleColVgpr scaleToBpe: sharedAddrVgpr <- cinRowPtr + coord0, scaled by BPE. BSHERE:coord0=8, coord0Vgpr=8 (multiple bpe)

/* rC *= alpha batchElements=[(0, 0, 0, 0)] */
v_mov_b32 v[vgprValuC+24], v[vgprValuC+0]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+25], v[vgprValuC+1]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+26], v[vgprValuC+2]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+27], v[vgprValuC+3]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+28], v[vgprValuC+4]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+29], v[vgprValuC+5]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+30], v[vgprValuC+6]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+31], v[vgprValuC+7]          // Rearrange MI out reg

/* apply mask, calc new C and issue writes */
buffer_store_b128 v[24:27], v15, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
buffer_store_b128 v[28:31], v15, s[sgprSrdD:sgprSrdD+3], null offen offset:16 // store D
s_nop 0                                            // 1 wait state required when next inst writes vgprs held by previous dwordx4 store inst
s_branch label_GW_End_1                            // jump to end
label_GW_B0_FD0_VW8_NonEdgeEnd_1:
label_GW_B0_FD0_VW8_Then_1:

/* edge=1, allocate 3 sgpr. perBatchTmpS=2 perBatchMaskS=1 perElementMaskS=0 elementsPerBatch=19 */
/* optSingleColVgpr=0 optSharedColVgpr=0 optSGPRUsage=BufferLoad_Edge_Mask optSrdIncForRow=0 factorDim=0 */

/******************************************/
/* Global Write Edge Batch #0 (d1,d0,vc1,vc0) = */
/*    (0,0,0,0:vw8)                       */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_mov_b32 v14, BufferOOB
/* (d1,vc1,d0,vc0)=(0,0,0,0) */
v_cmp_lt_u32 s30, v8, s[sgprSizeI]                 // coord0 < size0
v_cmp_lt_u32 s32, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s32, s30, s32                            // in0 && in1
v_add_lshl_u32 v15, v11, v8, 2                     // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v15, v14, v15, s32                   // LDD clip if OOB. offset

/* rC *= alpha batchElements=[(0, 0, 0, 0)] */
v_mov_b32 v[vgprValuC+16], v[vgprValuC+0]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+17], v[vgprValuC+1]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+18], v[vgprValuC+2]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+19], v[vgprValuC+3]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+20], v[vgprValuC+4]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+21], v[vgprValuC+5]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+22], v[vgprValuC+6]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+23], v[vgprValuC+7]          // Rearrange MI out reg

/* apply mask, calc new C and issue writes */
buffer_store_b128 v[16:19], v15, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
buffer_store_b128 v[20:23], v15, s[sgprSrdD:sgprSrdD+3], null offen offset:16 // store D
s_nop 0                                            // 1 wait state required when next inst writes vgprs held by previous dwordx4 store inst
s_branch label_GW_End_1                            // jump to end
label_GW_B0_FD0_VW8_Else_1:
label_GW_B0_FD0_VW1_Else:
label_GW_B0_FD0_VW1_Then:

/* edge=1, allocate 3 sgpr. perBatchTmpS=2 perBatchMaskS=1 perElementMaskS=0 elementsPerBatch=91 */
/* optSingleColVgpr=0 optSharedColVgpr=0 optSGPRUsage=BufferLoad_Edge_Mask optSrdIncForRow=0 factorDim=0 */

/******************************************/
/* Global Write Edge Batch #0 (d1,d0,vc1,vc0) = */
/*    (0,0,0,0:vw1); (0,0,0,1:vw1); (0,0,0,2:vw1); (0,0,0,3:vw1); (0,0,0,4:vw1); (0,0,0,5:vw1); (0,0,0,6:vw1); (0,0,0,7:vw1) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_mov_b32 v14, BufferOOB
/* (d1,vc1,d0,vc0)=(0,0,0,0) */
v_cmp_lt_u32 s30, v8, s[sgprSizeI]                 // coord0 < size0
v_cmp_lt_u32 s32, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s32, s30, s32                            // in0 && in1
v_add_lshl_u32 v23, v11, v8, 2                     // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v23, v14, v23, s32                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,1) */
v_add_co_u32 v12, vcc_lo, v8, 1                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s30, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s32, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s32, s30, s32                            // in0 && in1
v_add_lshl_u32 v24, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v24, v14, v24, s32                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,2) */
v_add_co_u32 v12, vcc_lo, v8, 2                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s30, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s32, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s32, s30, s32                            // in0 && in1
v_add_lshl_u32 v25, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v25, v14, v25, s32                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,3) */
v_add_co_u32 v12, vcc_lo, v8, 3                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s30, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s32, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s32, s30, s32                            // in0 && in1
v_add_lshl_u32 v26, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v26, v14, v26, s32                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,4) */
v_add_co_u32 v12, vcc_lo, v8, 4                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s30, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s32, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s32, s30, s32                            // in0 && in1
v_add_lshl_u32 v27, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v27, v14, v27, s32                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,5) */
v_add_co_u32 v12, vcc_lo, v8, 5                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s30, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s32, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s32, s30, s32                            // in0 && in1
v_add_lshl_u32 v28, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v28, v14, v28, s32                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,6) */
v_add_co_u32 v12, vcc_lo, v8, 6                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s30, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s32, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s32, s30, s32                            // in0 && in1
v_add_lshl_u32 v29, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v29, v14, v29, s32                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,7) */
v_add_co_u32 v12, vcc_lo, v8, 7                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s30, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s32, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s32, s30, s32                            // in0 && in1
v_add_lshl_u32 v30, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v30, v14, v30, s32                   // LDD clip if OOB. offset

/* rC *= alpha batchElements=[(0, 0, 0, 0), (0, 0, 0, 1), (0, 0, 0, 2), (0, 0, 0, 3), (0, 0, 0, 4), (0, 0, 0, 5), (0, 0, 0, 6), (0, 0, 0, 7)] */
v_mov_b32 v[vgprValuC+15], v[vgprValuC+0]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+16], v[vgprValuC+1]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+17], v[vgprValuC+2]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+18], v[vgprValuC+3]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+19], v[vgprValuC+4]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+20], v[vgprValuC+5]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+21], v[vgprValuC+6]          // Rearrange MI out reg
v_mov_b32 v[vgprValuC+22], v[vgprValuC+7]          // Rearrange MI out reg

/* apply mask, calc new C and issue writes */
buffer_store_b32 v15, v23, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
buffer_store_b32 v16, v24, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
buffer_store_b32 v17, v25, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
buffer_store_b32 v18, v26, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
buffer_store_b32 v19, v27, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
buffer_store_b32 v20, v28, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
buffer_store_b32 v21, v29, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
buffer_store_b32 v22, v30, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
s_nop 0                                            // 1 wait state required when next inst writes vgprs held by previous dwordx4 store inst
s_branch label_GW_End_1                            // jump to end
label_GW_End_1:
s_getpc_b64 s[30:31]                               // addr of next instr
s_add_i32 s32, label_KernelEnd, 4                  // target branch offset
s_add_u32 s30, s30, s32                            // add target branch offset
s_addc_u32 s31, s31, 0                             // add high and carry
s_setpc_b64 s[30:31]                               // branch to label_KernelEnd
label_GSU_5:
.set sgprAddressScaleAlphaVec, 48
.set sgprSrdScaleAlphaVec, 32
s_mov_b64 s[sgprSrdScaleAlphaVec+0:sgprSrdScaleAlphaVec+0+1], s[sgprAddressScaleAlphaVec+0:sgprAddressScaleAlphaVec+0+1] // init SRD base address
s_mov_b32 s[sgprSrdScaleAlphaVec+3], Srd127_96     // Set bits 127_96 in post-loop SRD
s_cmp_eq_u64 s[sgprAddressScaleAlphaVec:sgprAddressScaleAlphaVec+1], 0 // s[AddressScaleAlphaVec] == 0 ?
s_cbranch_scc0 label_ScaleAlphaVec_1AddrValid      // branch if s[AddressScaleAlphaVec] != 0
s_mov_b32 s[sgprSrdScaleAlphaVec+2], 0
s_branch label_ScaleAlphaVec_1AddrValid_End
label_ScaleAlphaVec_1AddrValid:
s_mov_b32 s[sgprSrdScaleAlphaVec+2], s[sgprSizeI]
label_ScaleAlphaVec_1AddrValid_End:

s_mul_i32 s[sgprSrdScaleAlphaVec+2], 0x4, s[sgprSrdScaleAlphaVec+2] // ScaleAlphaVec scaled by BPE
s_add_u32 s8, s[sgprWorkGroup2], 0x1
s_mul_i32 s8, s[sgprBiasStride], s8                // stride * (wg+1)
s_cmp_eq_u32 s8, 0                                 // bias stride = 0?
s_cselect_b32 s8, s[sgprSizeI], s8
s_mov_b64 s[sgprSrdBias+0:sgprSrdBias+0+1], s[sgprAddressBias+0:sgprAddressBias+0+1] // init SRD base address
s_mov_b32 s[sgprSrdBias+3], Srd127_96              // Set bits 127_96 in post-loop SRD
s_cmp_eq_u64 s[sgprAddressBias:sgprAddressBias+1], 0 // s[AddressBias] == 0 ?
s_cbranch_scc0 label_Bias_1AddrValid               // branch if s[AddressBias] != 0
s_mov_b32 s[sgprSrdBias+2], 0
s_branch label_Bias_1AddrValid_End
label_Bias_1AddrValid:
s_mov_b32 s[sgprSrdBias+2], s8
label_Bias_1AddrValid_End:


/******************************************/
/* Read vector to LDS                     */
/******************************************/
s_mul_i32 s8, 32, s[sgprWorkGroup0]                // wgp0 * MT0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_add_nc_u32 v16, s8, v[vgprSerial]                // coord 0 = wgp0 * MT0 + thread offset
s_mul_i32 s[sgprSrdBias+2], 0x4, s[sgprSrdBias+2]  // scaled by BPE
// Shift num records for gfx125x
s_and_b32 s8, s[sgprSrdBias+2], 127
s_lshl_b32 s8, s8, 25
s_and_b32 s[sgprSrdBias+1], s[sgprSrdBias+1], 33554431
s_or_b32 s[sgprSrdBias+1], s[sgprSrdBias+1], s8
s_lshr_b32 s[sgprSrdBias+2], s[sgprSrdBias+2], 7
s_mul_i32 s8, s[sgprBiasStride], s[sgprWorkGroup2] // Stride * WG
v_add_nc_u32 v14, s8, v16                          // coord 0 = wgp0 * MT0 + thread offset + Stride * WG
v_lshlrev_b32 v14, 0x2, v14                        // Global bias address scaled by BPE
v_lshlrev_b32 v15, 0x2, v16                        // Global scaleAlpha address scaled by BPE
s_mul_i32 s8, 32, s[sgprWorkGroup1]                // wgp1 * MT1
v_add_nc_u32 v16, s8, v[vgprSerial]                // coord 1 = wgp1 * MT1 + thread offset
buffer_load_b32 v12, v14, s[sgprSrdBias:sgprSrdBias+3], null offen offset:0 // Load Bias
buffer_load_b32 v13, v15, s[sgprSrdScaleAlphaVec:sgprSrdScaleAlphaVec+3], null offen offset:0 // Load ScaleAlphaVec
v_lshlrev_b32 v16, 0x2, v[vgprSerial]              // Local address scaled by BPE
s_barrier_signal -1
s_barrier_wait -1                                  // wait for all global loads.
s_wait_loadcnt 1                                   // wait for global load
ds_store_b32 v16, v12 offset:0                     // store bias
v_cmp_gt_u32 s[sgprAddressScaleAlphaVec], s[sgprSrdScaleAlphaVec+2], 0 //  == 0 ?
s_wait_loadcnt 0                                   // wait for global load
v_cndmask_b32 v13, 1.0, v13, s[sgprAddressScaleAlphaVec] // 1. mul 1 if 0
ds_store_b32 v16, v13 offset:512                   // store scaleAlpha
.set sgprAddressScaleAlphaVec, UNDEF
.set sgprSrdScaleAlphaVec, UNDEF
s_mov_b32 s11, 0
s_cmp_eq_u32 s[sgprBeta], s11                      // Beta == 0
s_cbranch_scc0 label_GW_B1                         // Branch if Beta is not zero

label_GW_B0_2:
label_GW_B0_FD0_2:
s_and_b32 s32, 31, s[sgprSizeI]                    // s32 = s[sgprSizeI] % 32
s_add_u32 s33, -0x1, s[sgprNumWorkGroups0]
s_cmp_ge_u32 s[sgprWorkGroup0], s33                // wg0 >= nwg0-1 ?
s_cselect_b32 s32, s32, 0                          // set rem
s_mov_b32 s8, 0
s_cmp_gt_u32 s32, s8                               // rem > 0
s_cbranch_scc1 label_GW_B0_FD0_VW8_Else_2          // jump if edges required
s_and_b32 s32, 31, s[sgprSizeJ]                    // s32 = s[sgprSizeJ] % 32
s_add_u32 s33, -0x1, s[sgprNumWorkGroups1]
s_cmp_ge_u32 s[sgprWorkGroup1], s33                // wg1 >= nwg1-1
s_cselect_b32 s32, s32, 0                          // set rem
s_mov_b32 s8, 0
s_cmp_gt_u32 s32, s8                               // rem > 0
s_cbranch_scc1 label_GW_B0_FD0_VW8_Then_2          // jump if edges required
label_GW_B0_FD0_VW8_NonEdge_2:
s_mov_b32 s8, 3
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 3
s_cbranch_scc1 label_To_Activation_Gelu_VW8_1_beta_0_1 // Branch if true
s_mov_b32 s8, 5
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 5
s_cbranch_scc1 label_To_Activation_Relu_VW8_1_beta_0_1 // Branch if true
s_mov_b32 s8, 6
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 6
s_cbranch_scc1 label_To_Activation_Sigmoid_VW8_1_beta_0_1 // Branch if true
s_mov_b32 s8, 11
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 11
s_cbranch_scc1 label_To_Activation_Silu_VW8_1_beta_0_1 // Branch if true
s_mov_b32 s8, 13
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 13
s_cbranch_scc1 label_To_Activation_Clamp_VW8_1_beta_0_1 // Branch if true
label_To_Activation_None_VW8_1_beta_0_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_None_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_6
label_To_Activation_Gelu_VW8_1_beta_0_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Gelu_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_6
label_To_Activation_Relu_VW8_1_beta_0_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Relu_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_6
label_To_Activation_Sigmoid_VW8_1_beta_0_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Sigmoid_VW8, 4      // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_6
label_To_Activation_Silu_VW8_1_beta_0_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Silu_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_6
label_To_Activation_Clamp_VW8_1_beta_0_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Clamp_VW8, 4        // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_6
label_ActivationSetPCAddrEnd_6:

/* edge=0, allocate 1 sgpr. perBatchTmpS=1 perBatchMaskS=0 perElementMaskS=0 elementsPerBatch=6 */
/* optSingleColVgpr=1 optSharedColVgpr=0 optSGPRUsage=BufferLoad_Mask optSrdIncForRow=1 factorDim=0 */

/******************************************/
/* Global Write Batch #0 (d1,d0,vc1,vc0) = */
/*    (0,0,0,0:vw8)                       */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,0,0) */
s_mul_i32 s8, 32, s[sgprWorkGroup0]                // wgp0 * MT0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_sub_nc_u32 v23, v8, s8
v_lshlrev_b32 v23, 0x2, v23                        // Bias address scaled by BPE
s_wait_dscnt 0                                     // Wait for LDS write
s_barrier_signal -1
s_barrier_wait -1                                  // LDS write barrier
ds_load_b128 v[32:35], v23 offset:0                // load Bias
ds_load_b128 v[36:39], v23 offset:16               // load Bias
ds_load_b128 v[40:43], v23 offset:512              // load scaleAlpha
ds_load_b128 v[44:47], v23 offset:528              // load scaleAlpha
v_add_lshl_u32 v21, v11, v8, 2                     // optSingleColVgpr scaleToBpe: sharedAddrVgpr <- cinRowPtr + coord0, scaled by BPE. BSHERE:coord0=8, coord0Vgpr=8 (multiple bpe)

/* rC *= alpha batchElements=[(0, 0, 0, 0)] */
v_mul_f32 v[vgprValuC+24], s[sgprAlpha], v[vgprValuC+0] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+25], s[sgprAlpha], v[vgprValuC+1] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+26], s[sgprAlpha], v[vgprValuC+2] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+27], s[sgprAlpha], v[vgprValuC+3] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+28], s[sgprAlpha], v[vgprValuC+4] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+29], s[sgprAlpha], v[vgprValuC+5] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+30], s[sgprAlpha], v[vgprValuC+6] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+31], s[sgprAlpha], v[vgprValuC+7] // Multiply MI out reg with alpha

/* apply mask, calc new C and issue writes */

s_wait_dscnt 0                                     // dscnt(0) = 4 - 2 (bias) - 2 (scaleAlphaVec) (interleaved)
v_pk_mul_f32 v[vgprValuC+24:vgprValuC+24+1], v[40:41], v[vgprValuC+24:vgprValuC+24+1] // *= ScaleAlphaVecVMulPK(40)(0)
v_pk_mul_f32 v[vgprValuC+26:vgprValuC+26+1], v[42:43], v[vgprValuC+26:vgprValuC+26+1] // *= ScaleAlphaVecVMulPK(40)(2)
v_pk_mul_f32 v[vgprValuC+28:vgprValuC+28+1], v[44:45], v[vgprValuC+28:vgprValuC+28+1] // *= ScaleAlphaVecVMulPK(40)(4)
v_pk_mul_f32 v[vgprValuC+30:vgprValuC+30+1], v[46:47], v[vgprValuC+30:vgprValuC+30+1] // *= ScaleAlphaVecVMulPK(40)(6)
v_pk_add_f32 v[12:13], v[32:33], v[vgprValuC+24:vgprValuC+24+1] // C += bias
v_pk_add_f32 v[14:15], v[34:35], v[vgprValuC+26:vgprValuC+26+1] // C += bias
v_pk_add_f32 v[16:17], v[36:37], v[vgprValuC+28:vgprValuC+28+1] // C += bias
v_pk_add_f32 v[18:19], v[38:39], v[vgprValuC+30:vgprValuC+30+1] // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b64 v[24:25], v[12:13]
v_mov_b64 v[26:27], v[14:15]
v_mov_b64 v[28:29], v[16:17]
v_mov_b64 v[30:31], v[18:19]
buffer_store_b128 v[24:27], v21, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
buffer_store_b128 v[28:31], v21, s[sgprSrdD:sgprSrdD+3], null offen offset:16 // store D
s_nop 0                                            // 1 wait state required when next inst writes vgprs held by previous dwordx4 store inst
s_branch label_GW_End_2                            // jump to end
label_GW_B0_FD0_VW8_NonEdgeEnd_2:
label_GW_B0_FD0_VW8_Then_2:
s_mov_b32 s8, 3
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 3
s_cbranch_scc1 label_To_Activation_Gelu_VW8_1_beta_0 // Branch if true
s_mov_b32 s8, 5
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 5
s_cbranch_scc1 label_To_Activation_Relu_VW8_1_beta_0 // Branch if true
s_mov_b32 s8, 6
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 6
s_cbranch_scc1 label_To_Activation_Sigmoid_VW8_1_beta_0 // Branch if true
s_mov_b32 s8, 11
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 11
s_cbranch_scc1 label_To_Activation_Silu_VW8_1_beta_0 // Branch if true
s_mov_b32 s8, 13
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 13
s_cbranch_scc1 label_To_Activation_Clamp_VW8_1_beta_0 // Branch if true
label_To_Activation_None_VW8_1_beta_0:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_None_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_5
label_To_Activation_Gelu_VW8_1_beta_0:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Gelu_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_5
label_To_Activation_Relu_VW8_1_beta_0:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Relu_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_5
label_To_Activation_Sigmoid_VW8_1_beta_0:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Sigmoid_VW8, 4      // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_5
label_To_Activation_Silu_VW8_1_beta_0:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Silu_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_5
label_To_Activation_Clamp_VW8_1_beta_0:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Clamp_VW8, 4        // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_5
label_ActivationSetPCAddrEnd_5:

/* edge=1, allocate 3 sgpr. perBatchTmpS=2 perBatchMaskS=1 perElementMaskS=0 elementsPerBatch=5 */
/* optSingleColVgpr=0 optSharedColVgpr=0 optSGPRUsage=BufferLoad_Edge_Mask optSrdIncForRow=0 factorDim=0 */

/******************************************/
/* Global Write Edge Batch #0 (d1,d0,vc1,vc0) = */
/*    (0,0,0,0:vw8)                       */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_mov_b32 v20, BufferOOB
/* (d1,vc1,d0,vc0)=(0,0,0,0) */
v_cmp_lt_u32 s32, v8, s[sgprSizeI]                 // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v22, v8, s32
v_lshlrev_b32 v22, 0x2, v22                        // Bias address scaled by BPE
s_wait_dscnt 0                                     // Wait for LDS write
s_barrier_signal -1
s_barrier_wait -1                                  // LDS write barrier
ds_load_b128 v[32:35], v22 offset:0                // load Bias
ds_load_b128 v[36:39], v22 offset:16               // load Bias
ds_load_b128 v[40:43], v22 offset:512              // load scaleAlpha
ds_load_b128 v[44:47], v22 offset:528              // load scaleAlpha
v_add_lshl_u32 v21, v11, v8, 2                     // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v21, v20, v21, s34                   // LDD clip if OOB. offset

/* rC *= alpha batchElements=[(0, 0, 0, 0)] */
v_mul_f32 v[vgprValuC+24], s[sgprAlpha], v[vgprValuC+0] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+25], s[sgprAlpha], v[vgprValuC+1] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+26], s[sgprAlpha], v[vgprValuC+2] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+27], s[sgprAlpha], v[vgprValuC+3] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+28], s[sgprAlpha], v[vgprValuC+4] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+29], s[sgprAlpha], v[vgprValuC+5] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+30], s[sgprAlpha], v[vgprValuC+6] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+31], s[sgprAlpha], v[vgprValuC+7] // Multiply MI out reg with alpha
s_wait_dscnt 0                                     // wait for Bias LDS, ScaleAlphaVec

/* apply mask, calc new C and issue writes */
v_pk_mul_f32 v[vgprValuC+24:vgprValuC+24+1], v[40:41], v[vgprValuC+24:vgprValuC+24+1] // *= ScaleAlphaVecVMulPK(40)(0)
v_pk_mul_f32 v[vgprValuC+26:vgprValuC+26+1], v[42:43], v[vgprValuC+26:vgprValuC+26+1] // *= ScaleAlphaVecVMulPK(40)(2)
v_pk_mul_f32 v[vgprValuC+28:vgprValuC+28+1], v[44:45], v[vgprValuC+28:vgprValuC+28+1] // *= ScaleAlphaVecVMulPK(40)(4)
v_pk_mul_f32 v[vgprValuC+30:vgprValuC+30+1], v[46:47], v[vgprValuC+30:vgprValuC+30+1] // *= ScaleAlphaVecVMulPK(40)(6)
v_pk_add_f32 v[12:13], v[32:33], v[vgprValuC+24:vgprValuC+24+1] // C += bias
v_pk_add_f32 v[14:15], v[34:35], v[vgprValuC+26:vgprValuC+26+1] // C += bias
v_pk_add_f32 v[16:17], v[36:37], v[vgprValuC+28:vgprValuC+28+1] // C += bias
v_pk_add_f32 v[18:19], v[38:39], v[vgprValuC+30:vgprValuC+30+1] // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b64 v[24:25], v[12:13]
v_mov_b64 v[26:27], v[14:15]
v_mov_b64 v[28:29], v[16:17]
v_mov_b64 v[30:31], v[18:19]
buffer_store_b128 v[24:27], v21, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
buffer_store_b128 v[28:31], v21, s[sgprSrdD:sgprSrdD+3], null offen offset:16 // store D
s_nop 0                                            // 1 wait state required when next inst writes vgprs held by previous dwordx4 store inst
s_branch label_GW_End_2                            // jump to end
label_GW_B0_FD0_VW8_Else_2:
label_GW_B0_FD0_VW1_Else_1:
label_GW_B0_FD0_VW1_Then_1:
s_mov_b32 s8, 3
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 3
s_cbranch_scc1 label_To_Activation_Gelu_VW1_beta_0 // Branch if true
s_mov_b32 s8, 5
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 5
s_cbranch_scc1 label_To_Activation_Relu_VW1_beta_0 // Branch if true
s_mov_b32 s8, 6
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 6
s_cbranch_scc1 label_To_Activation_Sigmoid_VW1_beta_0 // Branch if true
s_mov_b32 s8, 11
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 11
s_cbranch_scc1 label_To_Activation_Silu_VW1_beta_0 // Branch if true
s_mov_b32 s8, 13
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 13
s_cbranch_scc1 label_To_Activation_Clamp_VW1_beta_0 // Branch if true
label_To_Activation_None_VW1_beta_0:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_None_VW1, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_4
label_To_Activation_Gelu_VW1_beta_0:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Gelu_VW1, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_4
label_To_Activation_Relu_VW1_beta_0:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Relu_VW1, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_4
label_To_Activation_Sigmoid_VW1_beta_0:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Sigmoid_VW1, 4      // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_4
label_To_Activation_Silu_VW1_beta_0:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Silu_VW1, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_4
label_To_Activation_Clamp_VW1_beta_0:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Clamp_VW1, 4        // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_4
label_ActivationSetPCAddrEnd_4:

/* edge=1, allocate 3 sgpr. perBatchTmpS=2 perBatchMaskS=1 perElementMaskS=0 elementsPerBatch=35 */
/* optSingleColVgpr=0 optSharedColVgpr=0 optSGPRUsage=BufferLoad_Edge_Mask optSrdIncForRow=0 factorDim=0 */

/******************************************/
/* Global Write Edge Batch #0 (d1,d0,vc1,vc0) = */
/*    (0,0,0,0:vw1); (0,0,0,1:vw1); (0,0,0,2:vw1); (0,0,0,3:vw1); (0,0,0,4:vw1); (0,0,0,5:vw1); (0,0,0,6:vw1); (0,0,0,7:vw1) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_mov_b32 v20, BufferOOB
/* (d1,vc1,d0,vc0)=(0,0,0,0) */
v_cmp_lt_u32 s32, v8, s[sgprSizeI]                 // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v32, v8, s32
v_lshlrev_b32 v32, 0x2, v32                        // Bias address scaled by BPE
s_wait_dscnt 0                                     // Wait for LDS write
s_barrier_signal -1
s_barrier_wait -1                                  // LDS write barrier
ds_load_b32 v29, v32 offset:0                      // load Bias
ds_load_b32 v30, v32 offset:512                    // load scaleAlpha
v_add_lshl_u32 v31, v11, v8, 2                     // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v31, v20, v31, s34                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,1) */
v_add_co_u32 v12, vcc_lo, v8, 1                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s32, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v36, v12, s32
v_lshlrev_b32 v36, 0x2, v36                        // Bias address scaled by BPE
ds_load_b32 v33, v36 offset:0                      // load Bias
ds_load_b32 v34, v36 offset:512                    // load scaleAlpha
v_add_lshl_u32 v35, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v35, v20, v35, s34                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,2) */
v_add_co_u32 v12, vcc_lo, v8, 2                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s32, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v40, v12, s32
v_lshlrev_b32 v40, 0x2, v40                        // Bias address scaled by BPE
ds_load_b32 v37, v40 offset:0                      // load Bias
ds_load_b32 v38, v40 offset:512                    // load scaleAlpha
v_add_lshl_u32 v39, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v39, v20, v39, s34                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,3) */
v_add_co_u32 v12, vcc_lo, v8, 3                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s32, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v44, v12, s32
v_lshlrev_b32 v44, 0x2, v44                        // Bias address scaled by BPE
ds_load_b32 v41, v44 offset:0                      // load Bias
ds_load_b32 v42, v44 offset:512                    // load scaleAlpha
v_add_lshl_u32 v43, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v43, v20, v43, s34                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,4) */
v_add_co_u32 v12, vcc_lo, v8, 4                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s32, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v48, v12, s32
v_lshlrev_b32 v48, 0x2, v48                        // Bias address scaled by BPE
ds_load_b32 v45, v48 offset:0                      // load Bias
ds_load_b32 v46, v48 offset:512                    // load scaleAlpha
v_add_lshl_u32 v47, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v47, v20, v47, s34                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,5) */
v_add_co_u32 v12, vcc_lo, v8, 5                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s32, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v52, v12, s32
v_lshlrev_b32 v52, 0x2, v52                        // Bias address scaled by BPE
ds_load_b32 v49, v52 offset:0                      // load Bias
ds_load_b32 v50, v52 offset:512                    // load scaleAlpha
v_add_lshl_u32 v51, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v51, v20, v51, s34                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,6) */
v_add_co_u32 v12, vcc_lo, v8, 6                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s32, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v56, v12, s32
v_lshlrev_b32 v56, 0x2, v56                        // Bias address scaled by BPE
ds_load_b32 v53, v56 offset:0                      // load Bias
ds_load_b32 v54, v56 offset:512                    // load scaleAlpha
v_add_lshl_u32 v55, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v55, v20, v55, s34                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,7) */
v_add_co_u32 v12, vcc_lo, v8, 7                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s32, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v60, v12, s32
v_lshlrev_b32 v60, 0x2, v60                        // Bias address scaled by BPE
ds_load_b32 v57, v60 offset:0                      // load Bias
ds_load_b32 v58, v60 offset:512                    // load scaleAlpha
v_add_lshl_u32 v59, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v59, v20, v59, s34                   // LDD clip if OOB. offset

/* rC *= alpha batchElements=[(0, 0, 0, 0), (0, 0, 0, 1), (0, 0, 0, 2), (0, 0, 0, 3), (0, 0, 0, 4), (0, 0, 0, 5), (0, 0, 0, 6), (0, 0, 0, 7)] */
v_mul_f32 v[vgprValuC+21], s[sgprAlpha], v[vgprValuC+0] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+22], s[sgprAlpha], v[vgprValuC+1] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+23], s[sgprAlpha], v[vgprValuC+2] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+24], s[sgprAlpha], v[vgprValuC+3] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+25], s[sgprAlpha], v[vgprValuC+4] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+26], s[sgprAlpha], v[vgprValuC+5] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+27], s[sgprAlpha], v[vgprValuC+6] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+28], s[sgprAlpha], v[vgprValuC+7] // Multiply MI out reg with alpha
s_wait_dscnt 0                                     // wait for Bias LDS, ScaleAlphaVec

/* apply mask, calc new C and issue writes */
v_mul_f32 v[vgprValuC+21], v30, v[vgprValuC+21]    // *= ScaleAlphaVecVMul
v_add_f32 v12, v29, v[vgprValuC+21]                // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b32 v21, v12
buffer_store_b32 v21, v31, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
v_mul_f32 v[vgprValuC+22], v34, v[vgprValuC+22]    // *= ScaleAlphaVecVMul
v_add_f32 v12, v33, v[vgprValuC+22]                // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b32 v22, v12
buffer_store_b32 v22, v35, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
v_mul_f32 v[vgprValuC+23], v38, v[vgprValuC+23]    // *= ScaleAlphaVecVMul
v_add_f32 v12, v37, v[vgprValuC+23]                // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b32 v23, v12
buffer_store_b32 v23, v39, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
v_mul_f32 v[vgprValuC+24], v42, v[vgprValuC+24]    // *= ScaleAlphaVecVMul
v_add_f32 v12, v41, v[vgprValuC+24]                // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b32 v24, v12
buffer_store_b32 v24, v43, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
v_mul_f32 v[vgprValuC+25], v46, v[vgprValuC+25]    // *= ScaleAlphaVecVMul
v_add_f32 v12, v45, v[vgprValuC+25]                // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b32 v25, v12
buffer_store_b32 v25, v47, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
v_mul_f32 v[vgprValuC+26], v50, v[vgprValuC+26]    // *= ScaleAlphaVecVMul
v_add_f32 v12, v49, v[vgprValuC+26]                // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b32 v26, v12
buffer_store_b32 v26, v51, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
v_mul_f32 v[vgprValuC+27], v54, v[vgprValuC+27]    // *= ScaleAlphaVecVMul
v_add_f32 v12, v53, v[vgprValuC+27]                // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b32 v27, v12
buffer_store_b32 v27, v55, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
v_mul_f32 v[vgprValuC+28], v58, v[vgprValuC+28]    // *= ScaleAlphaVecVMul
v_add_f32 v12, v57, v[vgprValuC+28]                // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b32 v28, v12
buffer_store_b32 v28, v59, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
s_nop 0                                            // 1 wait state required when next inst writes vgprs held by previous dwordx4 store inst
s_branch label_GW_End_2                            // jump to end
label_GW_B1:
label_GW_B1_FD0:
s_and_b32 s32, 31, s[sgprSizeI]                    // s32 = s[sgprSizeI] % 32
s_add_u32 s33, -0x1, s[sgprNumWorkGroups0]
s_cmp_ge_u32 s[sgprWorkGroup0], s33                // wg0 >= nwg0-1 ?
s_cselect_b32 s32, s32, 0                          // set rem
s_mov_b32 s8, 0
s_cmp_gt_u32 s32, s8                               // rem > 0
s_cbranch_scc1 label_GW_B1_FD0_VW8_Else            // jump if edges required
s_and_b32 s32, 31, s[sgprSizeJ]                    // s32 = s[sgprSizeJ] % 32
s_add_u32 s33, -0x1, s[sgprNumWorkGroups1]
s_cmp_ge_u32 s[sgprWorkGroup1], s33                // wg1 >= nwg1-1
s_cselect_b32 s32, s32, 0                          // set rem
s_mov_b32 s8, 0
s_cmp_gt_u32 s32, s8                               // rem > 0
s_cbranch_scc1 label_GW_B1_FD0_VW8_Then            // jump if edges required
label_GW_B1_FD0_VW8_NonEdge:
s_mov_b32 s8, 3
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 3
s_cbranch_scc1 label_To_Activation_Gelu_VW8_1_beta_1_1 // Branch if true
s_mov_b32 s8, 5
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 5
s_cbranch_scc1 label_To_Activation_Relu_VW8_1_beta_1_1 // Branch if true
s_mov_b32 s8, 6
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 6
s_cbranch_scc1 label_To_Activation_Sigmoid_VW8_1_beta_1_1 // Branch if true
s_mov_b32 s8, 11
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 11
s_cbranch_scc1 label_To_Activation_Silu_VW8_1_beta_1_1 // Branch if true
s_mov_b32 s8, 13
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 13
s_cbranch_scc1 label_To_Activation_Clamp_VW8_1_beta_1_1 // Branch if true
label_To_Activation_None_VW8_1_beta_1_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_None_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_3
label_To_Activation_Gelu_VW8_1_beta_1_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Gelu_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_3
label_To_Activation_Relu_VW8_1_beta_1_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Relu_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_3
label_To_Activation_Sigmoid_VW8_1_beta_1_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Sigmoid_VW8, 4      // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_3
label_To_Activation_Silu_VW8_1_beta_1_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Silu_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_3
label_To_Activation_Clamp_VW8_1_beta_1_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Clamp_VW8, 4        // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_3
label_ActivationSetPCAddrEnd_3:

/* edge=0, allocate 1 sgpr. perBatchTmpS=1 perBatchMaskS=0 perElementMaskS=0 elementsPerBatch=5 */
/* optSingleColVgpr=1 optSharedColVgpr=0 optSGPRUsage=BufferLoad_Mask optSrdIncForRow=1 factorDim=0 */

/******************************************/
/* Global Write Beta Batch #0 (d1,d0,vc1,vc0) = */
/*    (0,0,0,0:vw8)                       */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,0,0) */
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_add_lshl_u32 v22, v10, v8, 2                     // optSingleColVgpr scaleToBpe: sharedAddrVgpr <- cinRowPtr + coord0, scaled by BPE. BSHERE:coord0=8, coord0Vgpr=8 (multiple bpe)
buffer_load_b128 v[32:35], v22, s[sgprSrdC:sgprSrdC+3], null offen offset:0 // load C
buffer_load_b128 v[36:39], v22, s[sgprSrdC:sgprSrdC+3], null offen offset:16 // load C
s_mul_i32 s8, 32, s[sgprWorkGroup0]                // wgp0 * MT0
v_sub_nc_u32 v23, v8, s8
v_lshlrev_b32 v23, 0x2, v23                        // Bias address scaled by BPE
s_wait_dscnt 0                                     // Wait for LDS write
s_barrier_signal -1
s_barrier_wait -1                                  // LDS write barrier
ds_load_b128 v[40:43], v23 offset:0                // load Bias
ds_load_b128 v[44:47], v23 offset:16               // load Bias
ds_load_b128 v[48:51], v23 offset:512              // load scaleAlpha
ds_load_b128 v[52:55], v23 offset:528              // load scaleAlpha
v_add_lshl_u32 v21, v11, v8, 2                     // optSingleColVgpr scaleToBpe: sharedAddrVgpr <- cinRowPtr + coord0, scaled by BPE. BSHERE:coord0=8, coord0Vgpr=8 (multiple bpe)

/* rC *= alpha batchElements=[(0, 0, 0, 0)] */
v_mul_f32 v[vgprValuC+24], s[sgprAlpha], v[vgprValuC+0] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+25], s[sgprAlpha], v[vgprValuC+1] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+26], s[sgprAlpha], v[vgprValuC+2] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+27], s[sgprAlpha], v[vgprValuC+3] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+28], s[sgprAlpha], v[vgprValuC+4] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+29], s[sgprAlpha], v[vgprValuC+5] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+30], s[sgprAlpha], v[vgprValuC+6] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+31], s[sgprAlpha], v[vgprValuC+7] // Multiply MI out reg with alpha

/* apply mask, calc new C and issue writes */

s_wait_dscnt 0                                     // vlcnt(0) = 2 - 2 (beta) dscnt(0) = 4 - 2 (bias) - 2 (scaleAlphaVec) (interleaved)
s_wait_loadcnt 0                                   // vlcnt(0) = 2 - 2 (beta) dscnt(0) = 4 - 2 (bias) - 2 (scaleAlphaVec) (interleaved)
v_pk_mul_f32 v[vgprValuC+24:vgprValuC+24+1], v[48:49], v[vgprValuC+24:vgprValuC+24+1] // *= ScaleAlphaVecVMulPK(48)(0)
v_pk_mul_f32 v[vgprValuC+26:vgprValuC+26+1], v[50:51], v[vgprValuC+26:vgprValuC+26+1] // *= ScaleAlphaVecVMulPK(48)(2)
v_pk_mul_f32 v[vgprValuC+28:vgprValuC+28+1], v[52:53], v[vgprValuC+28:vgprValuC+28+1] // *= ScaleAlphaVecVMulPK(48)(4)
v_pk_mul_f32 v[vgprValuC+30:vgprValuC+30+1], v[54:55], v[vgprValuC+30:vgprValuC+30+1] // *= ScaleAlphaVecVMulPK(48)(6)
v_fmac_f32 v[vgprValuC+24], v32, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_fmac_f32 v[vgprValuC+25], v33, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_fmac_f32 v[vgprValuC+26], v34, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_fmac_f32 v[vgprValuC+27], v35, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_fmac_f32 v[vgprValuC+28], v36, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_fmac_f32 v[vgprValuC+29], v37, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_fmac_f32 v[vgprValuC+30], v38, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_fmac_f32 v[vgprValuC+31], v39, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_pk_add_f32 v[12:13], v[40:41], v[vgprValuC+24:vgprValuC+24+1] // C += bias
v_pk_add_f32 v[14:15], v[42:43], v[vgprValuC+26:vgprValuC+26+1] // C += bias
v_pk_add_f32 v[16:17], v[44:45], v[vgprValuC+28:vgprValuC+28+1] // C += bias
v_pk_add_f32 v[18:19], v[46:47], v[vgprValuC+30:vgprValuC+30+1] // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b64 v[24:25], v[12:13]
v_mov_b64 v[26:27], v[14:15]
v_mov_b64 v[28:29], v[16:17]
v_mov_b64 v[30:31], v[18:19]
buffer_store_b128 v[24:27], v21, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
buffer_store_b128 v[28:31], v21, s[sgprSrdD:sgprSrdD+3], null offen offset:16 // store D
s_nop 0                                            // 1 wait state required when next inst writes vgprs held by previous dwordx4 store inst
s_branch label_GW_End_2                            // jump to end
label_GW_B1_FD0_VW8_NonEdgeEnd:
label_GW_B1_FD0_VW8_Then:
s_mov_b32 s8, 3
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 3
s_cbranch_scc1 label_To_Activation_Gelu_VW8_1_beta_1 // Branch if true
s_mov_b32 s8, 5
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 5
s_cbranch_scc1 label_To_Activation_Relu_VW8_1_beta_1 // Branch if true
s_mov_b32 s8, 6
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 6
s_cbranch_scc1 label_To_Activation_Sigmoid_VW8_1_beta_1 // Branch if true
s_mov_b32 s8, 11
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 11
s_cbranch_scc1 label_To_Activation_Silu_VW8_1_beta_1 // Branch if true
s_mov_b32 s8, 13
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 13
s_cbranch_scc1 label_To_Activation_Clamp_VW8_1_beta_1 // Branch if true
label_To_Activation_None_VW8_1_beta_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_None_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_2
label_To_Activation_Gelu_VW8_1_beta_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Gelu_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_2
label_To_Activation_Relu_VW8_1_beta_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Relu_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_2
label_To_Activation_Sigmoid_VW8_1_beta_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Sigmoid_VW8, 4      // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_2
label_To_Activation_Silu_VW8_1_beta_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Silu_VW8, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_2
label_To_Activation_Clamp_VW8_1_beta_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Clamp_VW8, 4        // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_2
label_ActivationSetPCAddrEnd_2:

/* edge=1, allocate 3 sgpr. perBatchTmpS=2 perBatchMaskS=1 perElementMaskS=0 elementsPerBatch=4 */
/* optSingleColVgpr=0 optSharedColVgpr=0 optSGPRUsage=BufferLoad_Edge_Mask optSrdIncForRow=0 factorDim=0 */

/******************************************/
/* Global Write Beta Edge Batch #0 (d1,d0,vc1,vc0) = */
/*    (0,0,0,0:vw8)                       */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_mov_b32 v20, BufferOOB
/* (d1,vc1,d0,vc0)=(0,0,0,0) */
v_cmp_lt_u32 s32, v8, s[sgprSizeI]                 // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
v_add_lshl_u32 v21, v10, v8, 2                     // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v21, v20, v21, s34                   // LDC clip if OOB. offset
buffer_load_b128 v[32:35], v21, s[sgprSrdC:sgprSrdC+3], null offen offset:0 // load C
buffer_load_b128 v[36:39], v21, s[sgprSrdC:sgprSrdC+3], null offen offset:16 // load C
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v22, v8, s32
v_lshlrev_b32 v22, 0x2, v22                        // Bias address scaled by BPE
s_wait_dscnt 0                                     // Wait for LDS write
s_barrier_signal -1
s_barrier_wait -1                                  // LDS write barrier
ds_load_b128 v[40:43], v22 offset:0                // load Bias
ds_load_b128 v[44:47], v22 offset:16               // load Bias
ds_load_b128 v[48:51], v22 offset:512              // load scaleAlpha
ds_load_b128 v[52:55], v22 offset:528              // load scaleAlpha
v_add_lshl_u32 v21, v11, v8, 2                     // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v21, v20, v21, s34                   // LDD clip if OOB. offset

/* rC *= alpha batchElements=[(0, 0, 0, 0)] */
v_mul_f32 v[vgprValuC+24], s[sgprAlpha], v[vgprValuC+0] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+25], s[sgprAlpha], v[vgprValuC+1] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+26], s[sgprAlpha], v[vgprValuC+2] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+27], s[sgprAlpha], v[vgprValuC+3] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+28], s[sgprAlpha], v[vgprValuC+4] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+29], s[sgprAlpha], v[vgprValuC+5] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+30], s[sgprAlpha], v[vgprValuC+6] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+31], s[sgprAlpha], v[vgprValuC+7] // Multiply MI out reg with alpha
s_wait_dscnt 0                                     // wait for Beta, Bias LDS, ScaleAlphaVec
s_wait_loadcnt 0                                   // wait for Beta, Bias LDS, ScaleAlphaVec

/* apply mask, calc new C and issue writes */
v_pk_mul_f32 v[vgprValuC+24:vgprValuC+24+1], v[48:49], v[vgprValuC+24:vgprValuC+24+1] // *= ScaleAlphaVecVMulPK(48)(0)
v_pk_mul_f32 v[vgprValuC+26:vgprValuC+26+1], v[50:51], v[vgprValuC+26:vgprValuC+26+1] // *= ScaleAlphaVecVMulPK(48)(2)
v_pk_mul_f32 v[vgprValuC+28:vgprValuC+28+1], v[52:53], v[vgprValuC+28:vgprValuC+28+1] // *= ScaleAlphaVecVMulPK(48)(4)
v_pk_mul_f32 v[vgprValuC+30:vgprValuC+30+1], v[54:55], v[vgprValuC+30:vgprValuC+30+1] // *= ScaleAlphaVecVMulPK(48)(6)
v_fmac_f32 v[vgprValuC+24], v32, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_fmac_f32 v[vgprValuC+25], v33, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_fmac_f32 v[vgprValuC+26], v34, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_fmac_f32 v[vgprValuC+27], v35, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_fmac_f32 v[vgprValuC+28], v36, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_fmac_f32 v[vgprValuC+29], v37, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_fmac_f32 v[vgprValuC+30], v38, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_fmac_f32 v[vgprValuC+31], v39, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_pk_add_f32 v[12:13], v[40:41], v[vgprValuC+24:vgprValuC+24+1] // C += bias
v_pk_add_f32 v[14:15], v[42:43], v[vgprValuC+26:vgprValuC+26+1] // C += bias
v_pk_add_f32 v[16:17], v[44:45], v[vgprValuC+28:vgprValuC+28+1] // C += bias
v_pk_add_f32 v[18:19], v[46:47], v[vgprValuC+30:vgprValuC+30+1] // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b64 v[24:25], v[12:13]
v_mov_b64 v[26:27], v[14:15]
v_mov_b64 v[28:29], v[16:17]
v_mov_b64 v[30:31], v[18:19]
buffer_store_b128 v[24:27], v21, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
buffer_store_b128 v[28:31], v21, s[sgprSrdD:sgprSrdD+3], null offen offset:16 // store D
s_nop 0                                            // 1 wait state required when next inst writes vgprs held by previous dwordx4 store inst
s_branch label_GW_End_2                            // jump to end
label_GW_B1_FD0_VW8_Else:
label_GW_B1_FD0_VW1_Else:
label_GW_B1_FD0_VW1_Then:
s_mov_b32 s8, 3
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 3
s_cbranch_scc1 label_To_Activation_Gelu_VW1_beta_1 // Branch if true
s_mov_b32 s8, 5
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 5
s_cbranch_scc1 label_To_Activation_Relu_VW1_beta_1 // Branch if true
s_mov_b32 s8, 6
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 6
s_cbranch_scc1 label_To_Activation_Sigmoid_VW1_beta_1 // Branch if true
s_mov_b32 s8, 11
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 11
s_cbranch_scc1 label_To_Activation_Silu_VW1_beta_1 // Branch if true
s_mov_b32 s8, 13
s_cmp_eq_u32 s[sgprActivationType], s8             // activationType == 13
s_cbranch_scc1 label_To_Activation_Clamp_VW1_beta_1 // Branch if true
label_To_Activation_None_VW1_beta_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_None_VW1, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_1
label_To_Activation_Gelu_VW1_beta_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Gelu_VW1, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_1
label_To_Activation_Relu_VW1_beta_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Relu_VW1, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_1
label_To_Activation_Sigmoid_VW1_beta_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Sigmoid_VW1, 4      // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_1
label_To_Activation_Silu_VW1_beta_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Silu_VW1, 4         // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_1
label_To_Activation_Clamp_VW1_beta_1:
s_getpc_b64 s[12:13]                               // addr of next instr
s_add_i32 s8, label_Activation_Clamp_VW1, 4        // target branch offset
s_add_u32 s12, s12, s8                             // add target branch offset
s_addc_u32 s13, s13, 0                             // add high and carry
s_branch label_ActivationSetPCAddrEnd_1
label_ActivationSetPCAddrEnd_1:

/* edge=1, allocate 3 sgpr. perBatchTmpS=2 perBatchMaskS=1 perElementMaskS=0 elementsPerBatch=29 */
/* optSingleColVgpr=0 optSharedColVgpr=0 optSGPRUsage=BufferLoad_Edge_Mask optSrdIncForRow=0 factorDim=0 */

/******************************************/
/* Global Write Beta Edge Batch #0 (d1,d0,vc1,vc0) = */
/*    (0,0,0,0:vw1); (0,0,0,1:vw1); (0,0,0,2:vw1); (0,0,0,3:vw1); (0,0,0,4:vw1); (0,0,0,5:vw1); (0,0,0,6:vw1); (0,0,0,7:vw1) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_mov_b32 v20, BufferOOB
/* (d1,vc1,d0,vc0)=(0,0,0,0) */
v_cmp_lt_u32 s32, v8, s[sgprSizeI]                 // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
v_add_lshl_u32 v32, v10, v8, 2                     // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v32, v20, v32, s34                   // LDC clip if OOB. offset
buffer_load_b32 v29, v32, s[sgprSrdC:sgprSrdC+3], null offen offset:0 // load C
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v33, v8, s32
v_lshlrev_b32 v33, 0x2, v33                        // Bias address scaled by BPE
s_wait_dscnt 0                                     // Wait for LDS write
s_barrier_signal -1
s_barrier_wait -1                                  // LDS write barrier
ds_load_b32 v30, v33 offset:0                      // load Bias
ds_load_b32 v31, v33 offset:512                    // load scaleAlpha
v_add_lshl_u32 v32, v11, v8, 2                     // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v32, v20, v32, s34                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,1) */
v_add_co_u32 v12, vcc_lo, v8, 1                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s32, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
v_add_lshl_u32 v37, v10, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v37, v20, v37, s34                   // LDC clip if OOB. offset
buffer_load_b32 v34, v37, s[sgprSrdC:sgprSrdC+3], null offen offset:0 // load C
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v38, v12, s32
v_lshlrev_b32 v38, 0x2, v38                        // Bias address scaled by BPE
ds_load_b32 v35, v38 offset:0                      // load Bias
ds_load_b32 v36, v38 offset:512                    // load scaleAlpha
v_add_lshl_u32 v37, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v37, v20, v37, s34                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,2) */
v_add_co_u32 v12, vcc_lo, v8, 2                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s32, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
v_add_lshl_u32 v42, v10, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v42, v20, v42, s34                   // LDC clip if OOB. offset
buffer_load_b32 v39, v42, s[sgprSrdC:sgprSrdC+3], null offen offset:0 // load C
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v43, v12, s32
v_lshlrev_b32 v43, 0x2, v43                        // Bias address scaled by BPE
ds_load_b32 v40, v43 offset:0                      // load Bias
ds_load_b32 v41, v43 offset:512                    // load scaleAlpha
v_add_lshl_u32 v42, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v42, v20, v42, s34                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,3) */
v_add_co_u32 v12, vcc_lo, v8, 3                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s32, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
v_add_lshl_u32 v47, v10, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v47, v20, v47, s34                   // LDC clip if OOB. offset
buffer_load_b32 v44, v47, s[sgprSrdC:sgprSrdC+3], null offen offset:0 // load C
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v48, v12, s32
v_lshlrev_b32 v48, 0x2, v48                        // Bias address scaled by BPE
ds_load_b32 v45, v48 offset:0                      // load Bias
ds_load_b32 v46, v48 offset:512                    // load scaleAlpha
v_add_lshl_u32 v47, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v47, v20, v47, s34                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,4) */
v_add_co_u32 v12, vcc_lo, v8, 4                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s32, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
v_add_lshl_u32 v52, v10, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v52, v20, v52, s34                   // LDC clip if OOB. offset
buffer_load_b32 v49, v52, s[sgprSrdC:sgprSrdC+3], null offen offset:0 // load C
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v53, v12, s32
v_lshlrev_b32 v53, 0x2, v53                        // Bias address scaled by BPE
ds_load_b32 v50, v53 offset:0                      // load Bias
ds_load_b32 v51, v53 offset:512                    // load scaleAlpha
v_add_lshl_u32 v52, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v52, v20, v52, s34                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,5) */
v_add_co_u32 v12, vcc_lo, v8, 5                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s32, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
v_add_lshl_u32 v57, v10, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v57, v20, v57, s34                   // LDC clip if OOB. offset
buffer_load_b32 v54, v57, s[sgprSrdC:sgprSrdC+3], null offen offset:0 // load C
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v58, v12, s32
v_lshlrev_b32 v58, 0x2, v58                        // Bias address scaled by BPE
ds_load_b32 v55, v58 offset:0                      // load Bias
ds_load_b32 v56, v58 offset:512                    // load scaleAlpha
v_add_lshl_u32 v57, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v57, v20, v57, s34                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,6) */
v_add_co_u32 v12, vcc_lo, v8, 6                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s32, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
v_add_lshl_u32 v62, v10, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v62, v20, v62, s34                   // LDC clip if OOB. offset
buffer_load_b32 v59, v62, s[sgprSrdC:sgprSrdC+3], null offen offset:0 // load C
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v63, v12, s32
v_lshlrev_b32 v63, 0x2, v63                        // Bias address scaled by BPE
ds_load_b32 v60, v63 offset:0                      // load Bias
ds_load_b32 v61, v63 offset:512                    // load scaleAlpha
v_add_lshl_u32 v62, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v62, v20, v62, s34                   // LDD clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,7) */
v_add_co_u32 v12, vcc_lo, v8, 7                    // coord0.1: coord0 += d0*sg0*VW + vc0
v_cmp_lt_u32 s32, v12, s[sgprSizeI]                // coord0 < size0
v_cmp_lt_u32 s34, v9, s[sgprSizeJ]                 // coord1 < size1
s_and_b32 s34, s32, s34                            // in0 && in1
v_add_lshl_u32 v68, v10, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v68, v20, v68, s34                   // LDC clip if OOB. offset
buffer_load_b32 v64, v68, s[sgprSrdC:sgprSrdC+3], null offen offset:0 // load C
s_mul_i32 s32, 32, s[sgprWorkGroup0]               // wgp0 * MT0
v_sub_nc_u32 v69, v12, s32
v_lshlrev_b32 v69, 0x2, v69                        // Bias address scaled by BPE
ds_load_b32 v65, v69 offset:0                      // load Bias
ds_load_b32 v67, v69 offset:512                    // load scaleAlpha
v_add_lshl_u32 v68, v11, v12, 2                    // scaleToBpe: accumulate d0 lower and *= bpe into Cin addr (multiple bpe)
v_cndmask_b32 v68, v20, v68, s34                   // LDD clip if OOB. offset

/* rC *= alpha batchElements=[(0, 0, 0, 0), (0, 0, 0, 1), (0, 0, 0, 2), (0, 0, 0, 3), (0, 0, 0, 4), (0, 0, 0, 5), (0, 0, 0, 6), (0, 0, 0, 7)] */
v_mul_f32 v[vgprValuC+21], s[sgprAlpha], v[vgprValuC+0] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+22], s[sgprAlpha], v[vgprValuC+1] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+23], s[sgprAlpha], v[vgprValuC+2] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+24], s[sgprAlpha], v[vgprValuC+3] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+25], s[sgprAlpha], v[vgprValuC+4] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+26], s[sgprAlpha], v[vgprValuC+5] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+27], s[sgprAlpha], v[vgprValuC+6] // Multiply MI out reg with alpha
v_mul_f32 v[vgprValuC+28], s[sgprAlpha], v[vgprValuC+7] // Multiply MI out reg with alpha
s_wait_dscnt 0                                     // wait for Beta, Bias LDS, ScaleAlphaVec
s_wait_loadcnt 0                                   // wait for Beta, Bias LDS, ScaleAlphaVec

/* apply mask, calc new C and issue writes */
v_mul_f32 v[vgprValuC+21], v31, v[vgprValuC+21]    // *= ScaleAlphaVecVMul
v_fmac_f32 v[vgprValuC+21], v29, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_add_f32 v12, v30, v[vgprValuC+21]                // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b32 v21, v12
buffer_store_b32 v21, v32, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
v_mul_f32 v[vgprValuC+22], v36, v[vgprValuC+22]    // *= ScaleAlphaVecVMul
v_fmac_f32 v[vgprValuC+22], v34, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_add_f32 v12, v35, v[vgprValuC+22]                // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b32 v22, v12
buffer_store_b32 v22, v37, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
v_mul_f32 v[vgprValuC+23], v41, v[vgprValuC+23]    // *= ScaleAlphaVecVMul
v_fmac_f32 v[vgprValuC+23], v39, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_add_f32 v12, v40, v[vgprValuC+23]                // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b32 v23, v12
buffer_store_b32 v23, v42, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
v_mul_f32 v[vgprValuC+24], v46, v[vgprValuC+24]    // *= ScaleAlphaVecVMul
v_fmac_f32 v[vgprValuC+24], v44, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_add_f32 v12, v45, v[vgprValuC+24]                // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b32 v24, v12
buffer_store_b32 v24, v47, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
v_mul_f32 v[vgprValuC+25], v51, v[vgprValuC+25]    // *= ScaleAlphaVecVMul
v_fmac_f32 v[vgprValuC+25], v49, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_add_f32 v12, v50, v[vgprValuC+25]                // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b32 v25, v12
buffer_store_b32 v25, v52, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
v_mul_f32 v[vgprValuC+26], v56, v[vgprValuC+26]    // *= ScaleAlphaVecVMul
v_fmac_f32 v[vgprValuC+26], v54, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_add_f32 v12, v55, v[vgprValuC+26]                // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b32 v26, v12
buffer_store_b32 v26, v57, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
v_mul_f32 v[vgprValuC+27], v61, v[vgprValuC+27]    // *= ScaleAlphaVecVMul
v_fmac_f32 v[vgprValuC+27], v59, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_add_f32 v12, v60, v[vgprValuC+27]                // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b32 v27, v12
buffer_store_b32 v27, v62, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
v_mul_f32 v[vgprValuC+28], v67, v[vgprValuC+28]    // *= ScaleAlphaVecVMul
v_fmac_f32 v[vgprValuC+28], v64, s[sgprBeta]       // finalSum = sum*alpha + C*beta
v_add_f32 v12, v65, v[vgprValuC+28]                // C += bias
s_swappc_b64 s[30:31], s[12:13]
v_mov_b32 v28, v12
buffer_store_b32 v28, v68, s[sgprSrdD:sgprSrdD+3], null offen offset:0 // store D
s_nop 0                                            // 1 wait state required when next inst writes vgprs held by previous dwordx4 store inst
s_branch label_GW_End_2                            // jump to end
label_Activation_None_VW1:
s_setpc_b64 s[30:31]
label_Activation_Gelu_VW1:
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_mul_f32 v20, 0x3d372713, v12                     // k1 * x
v_fma_f32 v20, v12, v20, 1.0                       // 1 + (k1 * x * x)
v_mul_f32 v20, v12, v20                            // x * (1 + k1 * x * x)
v_mul_f32 v20, 0x40135761, v20                     //  (fused 2.302208)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // e^2x + 1
v_rcp_f32 v20, v20                                 // 1 / (e^2x + 1)
v_fma_f32 v20, -2.0, v20, 2.0                      //  ( + 1 (fused))
v_mul_f32 v20, v12, v20                            // x * (1 + tanh(...))
v_mul_f32 v12, 0.5, v20                            // 0.5 * x * (1 + tanh(...))
s_setpc_b64 s[30:31]
label_Activation_Relu_VW1:
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_max_f32 v12, v12, 0                              // x = max(0, x)
s_setpc_b64 s[30:31]
label_Activation_Sigmoid_VW1:
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_mul_f32 v12, 0xbfb8aa3b, v12                     //  (fused -1.442695)
v_exp_f32 v12, v12                                 // exp step 2
v_add_f32 v12, 1.0, v12                            // 1 + exp(-x)
v_rcp_f32 v12, v12                                 // 1 / (1 + exp(-x))
s_setpc_b64 s[30:31]
label_Activation_Silu_VW1:
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_mul_f32 v20, -1.4426950408889634, v12            //  (fused -1.442695)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // 1 + exp(-x)
v_rcp_f32 v20, v20                                 // 1 / (1 + exp(-x))
v_mul_f32 v12, v12, v20                            // x / (1 + exp(-x))
s_setpc_b64 s[30:31]
label_Activation_Clamp_VW1:
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_min_f32 v12, s[sgpractivationBeta], v12          // min(x, beta)
v_max_f32 v12, s[sgpractivationAlpha], v12         // max(alpha, min(x, beta))
s_setpc_b64 s[30:31]
label_GW_End_2:
label_KernelEnd:
s_endpgm                                           // Kernel End
label_ASM_End:  /// The end of the kernel
label_Activation_None_VW8:
s_setpc_b64 s[30:31]
label_Activation_Gelu_VW8:
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_mul_f32 v20, 0x3d372713, v12                     // k1 * x
v_fma_f32 v20, v12, v20, 1.0                       // 1 + (k1 * x * x)
v_mul_f32 v20, v12, v20                            // x * (1 + k1 * x * x)
v_mul_f32 v20, 0x40135761, v20                     //  (fused 2.302208)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // e^2x + 1
v_rcp_f32 v20, v20                                 // 1 / (e^2x + 1)
v_fma_f32 v20, -2.0, v20, 2.0                      //  ( + 1 (fused))
v_mul_f32 v20, v12, v20                            // x * (1 + tanh(...))
v_mul_f32 v12, 0.5, v20                            // 0.5 * x * (1 + tanh(...))
v_mul_f32 v20, 0x3d372713, v13                     // k1 * x
v_fma_f32 v20, v13, v20, 1.0                       // 1 + (k1 * x * x)
v_mul_f32 v20, v13, v20                            // x * (1 + k1 * x * x)
v_mul_f32 v20, 0x40135761, v20                     //  (fused 2.302208)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // e^2x + 1
v_rcp_f32 v20, v20                                 // 1 / (e^2x + 1)
v_fma_f32 v20, -2.0, v20, 2.0                      //  ( + 1 (fused))
v_mul_f32 v20, v13, v20                            // x * (1 + tanh(...))
v_mul_f32 v13, 0.5, v20                            // 0.5 * x * (1 + tanh(...))
v_mul_f32 v20, 0x3d372713, v14                     // k1 * x
v_fma_f32 v20, v14, v20, 1.0                       // 1 + (k1 * x * x)
v_mul_f32 v20, v14, v20                            // x * (1 + k1 * x * x)
v_mul_f32 v20, 0x40135761, v20                     //  (fused 2.302208)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // e^2x + 1
v_rcp_f32 v20, v20                                 // 1 / (e^2x + 1)
v_fma_f32 v20, -2.0, v20, 2.0                      //  ( + 1 (fused))
v_mul_f32 v20, v14, v20                            // x * (1 + tanh(...))
v_mul_f32 v14, 0.5, v20                            // 0.5 * x * (1 + tanh(...))
v_mul_f32 v20, 0x3d372713, v15                     // k1 * x
v_fma_f32 v20, v15, v20, 1.0                       // 1 + (k1 * x * x)
v_mul_f32 v20, v15, v20                            // x * (1 + k1 * x * x)
v_mul_f32 v20, 0x40135761, v20                     //  (fused 2.302208)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // e^2x + 1
v_rcp_f32 v20, v20                                 // 1 / (e^2x + 1)
v_fma_f32 v20, -2.0, v20, 2.0                      //  ( + 1 (fused))
v_mul_f32 v20, v15, v20                            // x * (1 + tanh(...))
v_mul_f32 v15, 0.5, v20                            // 0.5 * x * (1 + tanh(...))
v_mul_f32 v20, 0x3d372713, v16                     // k1 * x
v_fma_f32 v20, v16, v20, 1.0                       // 1 + (k1 * x * x)
v_mul_f32 v20, v16, v20                            // x * (1 + k1 * x * x)
v_mul_f32 v20, 0x40135761, v20                     //  (fused 2.302208)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // e^2x + 1
v_rcp_f32 v20, v20                                 // 1 / (e^2x + 1)
v_fma_f32 v20, -2.0, v20, 2.0                      //  ( + 1 (fused))
v_mul_f32 v20, v16, v20                            // x * (1 + tanh(...))
v_mul_f32 v16, 0.5, v20                            // 0.5 * x * (1 + tanh(...))
v_mul_f32 v20, 0x3d372713, v17                     // k1 * x
v_fma_f32 v20, v17, v20, 1.0                       // 1 + (k1 * x * x)
v_mul_f32 v20, v17, v20                            // x * (1 + k1 * x * x)
v_mul_f32 v20, 0x40135761, v20                     //  (fused 2.302208)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // e^2x + 1
v_rcp_f32 v20, v20                                 // 1 / (e^2x + 1)
v_fma_f32 v20, -2.0, v20, 2.0                      //  ( + 1 (fused))
v_mul_f32 v20, v17, v20                            // x * (1 + tanh(...))
v_mul_f32 v17, 0.5, v20                            // 0.5 * x * (1 + tanh(...))
v_mul_f32 v20, 0x3d372713, v18                     // k1 * x
v_fma_f32 v20, v18, v20, 1.0                       // 1 + (k1 * x * x)
v_mul_f32 v20, v18, v20                            // x * (1 + k1 * x * x)
v_mul_f32 v20, 0x40135761, v20                     //  (fused 2.302208)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // e^2x + 1
v_rcp_f32 v20, v20                                 // 1 / (e^2x + 1)
v_fma_f32 v20, -2.0, v20, 2.0                      //  ( + 1 (fused))
v_mul_f32 v20, v18, v20                            // x * (1 + tanh(...))
v_mul_f32 v18, 0.5, v20                            // 0.5 * x * (1 + tanh(...))
v_mul_f32 v20, 0x3d372713, v19                     // k1 * x
v_fma_f32 v20, v19, v20, 1.0                       // 1 + (k1 * x * x)
v_mul_f32 v20, v19, v20                            // x * (1 + k1 * x * x)
v_mul_f32 v20, 0x40135761, v20                     //  (fused 2.302208)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // e^2x + 1
v_rcp_f32 v20, v20                                 // 1 / (e^2x + 1)
v_fma_f32 v20, -2.0, v20, 2.0                      //  ( + 1 (fused))
v_mul_f32 v20, v19, v20                            // x * (1 + tanh(...))
v_mul_f32 v19, 0.5, v20                            // 0.5 * x * (1 + tanh(...))
s_setpc_b64 s[30:31]
label_Activation_Relu_VW8:
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_max_f32 v12, v12, 0                              // x = max(0, x)
v_max_f32 v13, v13, 0                              // x = max(0, x)
v_max_f32 v14, v14, 0                              // x = max(0, x)
v_max_f32 v15, v15, 0                              // x = max(0, x)
v_max_f32 v16, v16, 0                              // x = max(0, x)
v_max_f32 v17, v17, 0                              // x = max(0, x)
v_max_f32 v18, v18, 0                              // x = max(0, x)
v_max_f32 v19, v19, 0                              // x = max(0, x)
s_setpc_b64 s[30:31]
label_Activation_Sigmoid_VW8:
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_mul_f32 v12, 0xbfb8aa3b, v12                     //  (fused -1.442695)
v_exp_f32 v12, v12                                 // exp step 2
v_add_f32 v12, 1.0, v12                            // 1 + exp(-x)
v_rcp_f32 v12, v12                                 // 1 / (1 + exp(-x))
v_mul_f32 v13, 0xbfb8aa3b, v13                     //  (fused -1.442695)
v_exp_f32 v13, v13                                 // exp step 2
v_add_f32 v13, 1.0, v13                            // 1 + exp(-x)
v_rcp_f32 v13, v13                                 // 1 / (1 + exp(-x))
v_mul_f32 v14, 0xbfb8aa3b, v14                     //  (fused -1.442695)
v_exp_f32 v14, v14                                 // exp step 2
v_add_f32 v14, 1.0, v14                            // 1 + exp(-x)
v_rcp_f32 v14, v14                                 // 1 / (1 + exp(-x))
v_mul_f32 v15, 0xbfb8aa3b, v15                     //  (fused -1.442695)
v_exp_f32 v15, v15                                 // exp step 2
v_add_f32 v15, 1.0, v15                            // 1 + exp(-x)
v_rcp_f32 v15, v15                                 // 1 / (1 + exp(-x))
v_mul_f32 v16, 0xbfb8aa3b, v16                     //  (fused -1.442695)
v_exp_f32 v16, v16                                 // exp step 2
v_add_f32 v16, 1.0, v16                            // 1 + exp(-x)
v_rcp_f32 v16, v16                                 // 1 / (1 + exp(-x))
v_mul_f32 v17, 0xbfb8aa3b, v17                     //  (fused -1.442695)
v_exp_f32 v17, v17                                 // exp step 2
v_add_f32 v17, 1.0, v17                            // 1 + exp(-x)
v_rcp_f32 v17, v17                                 // 1 / (1 + exp(-x))
v_mul_f32 v18, 0xbfb8aa3b, v18                     //  (fused -1.442695)
v_exp_f32 v18, v18                                 // exp step 2
v_add_f32 v18, 1.0, v18                            // 1 + exp(-x)
v_rcp_f32 v18, v18                                 // 1 / (1 + exp(-x))
v_mul_f32 v19, 0xbfb8aa3b, v19                     //  (fused -1.442695)
v_exp_f32 v19, v19                                 // exp step 2
v_add_f32 v19, 1.0, v19                            // 1 + exp(-x)
v_rcp_f32 v19, v19                                 // 1 / (1 + exp(-x))
s_setpc_b64 s[30:31]
label_Activation_Silu_VW8:
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_mul_f32 v20, -1.4426950408889634, v12            //  (fused -1.442695)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // 1 + exp(-x)
v_rcp_f32 v20, v20                                 // 1 / (1 + exp(-x))
v_mul_f32 v12, v12, v20                            // x / (1 + exp(-x))
v_mul_f32 v20, -1.4426950408889634, v13            //  (fused -1.442695)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // 1 + exp(-x)
v_rcp_f32 v20, v20                                 // 1 / (1 + exp(-x))
v_mul_f32 v13, v13, v20                            // x / (1 + exp(-x))
v_mul_f32 v20, -1.4426950408889634, v14            //  (fused -1.442695)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // 1 + exp(-x)
v_rcp_f32 v20, v20                                 // 1 / (1 + exp(-x))
v_mul_f32 v14, v14, v20                            // x / (1 + exp(-x))
v_mul_f32 v20, -1.4426950408889634, v15            //  (fused -1.442695)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // 1 + exp(-x)
v_rcp_f32 v20, v20                                 // 1 / (1 + exp(-x))
v_mul_f32 v15, v15, v20                            // x / (1 + exp(-x))
v_mul_f32 v20, -1.4426950408889634, v16            //  (fused -1.442695)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // 1 + exp(-x)
v_rcp_f32 v20, v20                                 // 1 / (1 + exp(-x))
v_mul_f32 v16, v16, v20                            // x / (1 + exp(-x))
v_mul_f32 v20, -1.4426950408889634, v17            //  (fused -1.442695)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // 1 + exp(-x)
v_rcp_f32 v20, v20                                 // 1 / (1 + exp(-x))
v_mul_f32 v17, v17, v20                            // x / (1 + exp(-x))
v_mul_f32 v20, -1.4426950408889634, v18            //  (fused -1.442695)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // 1 + exp(-x)
v_rcp_f32 v20, v20                                 // 1 / (1 + exp(-x))
v_mul_f32 v18, v18, v20                            // x / (1 + exp(-x))
v_mul_f32 v20, -1.4426950408889634, v19            //  (fused -1.442695)
v_exp_f32 v20, v20                                 // exp step 2
v_add_f32 v20, 1.0, v20                            // 1 + exp(-x)
v_rcp_f32 v20, v20                                 // 1 / (1 + exp(-x))
v_mul_f32 v19, v19, v20                            // x / (1 + exp(-x))
s_setpc_b64 s[30:31]
label_Activation_Clamp_VW8:
s_nop 0
s_set_vgpr_msb 0                                   // src0: 0, src1: 0, src2: 0, dst: 0
v_min_f32 v12, s[sgpractivationBeta], v12          // min(x, beta)
v_max_f32 v12, s[sgpractivationAlpha], v12         // max(alpha, min(x, beta))
v_min_f32 v13, s[sgpractivationBeta], v13          // min(x, beta)
v_max_f32 v13, s[sgpractivationAlpha], v13         // max(alpha, min(x, beta))
v_min_f32 v14, s[sgpractivationBeta], v14          // min(x, beta)
v_max_f32 v14, s[sgpractivationAlpha], v14         // max(alpha, min(x, beta))
v_min_f32 v15, s[sgpractivationBeta], v15          // min(x, beta)
v_max_f32 v15, s[sgpractivationAlpha], v15         // max(alpha, min(x, beta))
v_min_f32 v16, s[sgpractivationBeta], v16          // min(x, beta)
v_max_f32 v16, s[sgpractivationAlpha], v16         // max(alpha, min(x, beta))
v_min_f32 v17, s[sgpractivationBeta], v17          // min(x, beta)
v_max_f32 v17, s[sgpractivationAlpha], v17         // max(alpha, min(x, beta))
v_min_f32 v18, s[sgpractivationBeta], v18          // min(x, beta)
v_max_f32 v18, s[sgpractivationAlpha], v18         // max(alpha, min(x, beta))
v_min_f32 v19, s[sgpractivationBeta], v19          // min(x, beta)
v_max_f32 v19, s[sgpractivationAlpha], v19         // max(alpha, min(x, beta))
s_setpc_b64 s[30:31]
s_endpgm
