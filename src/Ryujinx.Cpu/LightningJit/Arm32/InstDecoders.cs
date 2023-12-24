namespace Ryujinx.Cpu.LightningJit.Arm32
{
    struct InstCondb28w4Sb20w1Rnb16w4Rdb12w4Imm12b0w12
    {
        private readonly uint _value;
        public InstCondb28w4Sb20w1Rnb16w4Rdb12w4Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint Rd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint S => (_value >> 20) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstIb26w1Sb20w1Rnb16w4Imm3b12w3Rdb8w4Imm8b0w8
    {
        private readonly uint _value;
        public InstIb26w1Sb20w1Rnb16w4Imm3b12w3Rdb8w4Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Imm3 => (_value >> 12) & 0x7;
        public uint Rn => (_value >> 16) & 0xF;
        public uint S => (_value >> 20) & 0x1;
        public uint I => (_value >> 26) & 0x1;
    }

    struct InstCondb28w4Sb20w1Rnb16w4Rdb12w4Imm5b7w5Stypeb5w2Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Sb20w1Rnb16w4Rdb12w4Imm5b7w5Stypeb5w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Stype => (_value >> 5) & 0x3;
        public uint Imm5 => (_value >> 7) & 0x1F;
        public uint Rd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint S => (_value >> 20) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRmb19w3Rdnb16w3
    {
        private readonly uint _value;
        public InstRmb19w3Rdnb16w3(uint value) => _value = value;
        public uint Rdn => (_value >> 16) & 0x7;
        public uint Rm => (_value >> 19) & 0x7;
    }

    struct InstSb20w1Rnb16w4Imm3b12w3Rdb8w4Imm2b6w2Stypeb4w2Rmb0w4
    {
        private readonly uint _value;
        public InstSb20w1Rnb16w4Imm3b12w3Rdb8w4Imm2b6w2Stypeb4w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Stype => (_value >> 4) & 0x3;
        public uint Imm2 => (_value >> 6) & 0x3;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Imm3 => (_value >> 12) & 0x7;
        public uint Rn => (_value >> 16) & 0xF;
        public uint S => (_value >> 20) & 0x1;
    }

    struct InstCondb28w4Sb20w1Rnb16w4Rdb12w4Rsb8w4Stypeb5w2Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Sb20w1Rnb16w4Rdb12w4Rsb8w4Stypeb5w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Stype => (_value >> 5) & 0x3;
        public uint Rs => (_value >> 8) & 0xF;
        public uint Rd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint S => (_value >> 20) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstImm3b22w3Rnb19w3Rdb16w3
    {
        private readonly uint _value;
        public InstImm3b22w3Rnb19w3Rdb16w3(uint value) => _value = value;
        public uint Rd => (_value >> 16) & 0x7;
        public uint Rn => (_value >> 19) & 0x7;
        public uint Imm3 => (_value >> 22) & 0x7;
    }

    struct InstRdnb24w3Imm8b16w8
    {
        private readonly uint _value;
        public InstRdnb24w3Imm8b16w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 16) & 0xFF;
        public uint Rdn => (_value >> 24) & 0x7;
    }

    struct InstIb26w1Rnb16w4Imm3b12w3Rdb8w4Imm8b0w8
    {
        private readonly uint _value;
        public InstIb26w1Rnb16w4Imm3b12w3Rdb8w4Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Imm3 => (_value >> 12) & 0x7;
        public uint Rn => (_value >> 16) & 0xF;
        public uint I => (_value >> 26) & 0x1;
    }

    struct InstRmb22w3Rnb19w3Rdb16w3
    {
        private readonly uint _value;
        public InstRmb22w3Rnb19w3Rdb16w3(uint value) => _value = value;
        public uint Rd => (_value >> 16) & 0x7;
        public uint Rn => (_value >> 19) & 0x7;
        public uint Rm => (_value >> 22) & 0x7;
    }

    struct InstDnb23w1Rmb19w4Rdnb16w3
    {
        private readonly uint _value;
        public InstDnb23w1Rmb19w4Rdnb16w3(uint value) => _value = value;
        public uint Rdn => (_value >> 16) & 0x7;
        public uint Rm => (_value >> 19) & 0xF;
        public uint Dn => (_value >> 23) & 0x1;
    }

    struct InstCondb28w4Sb20w1Rdb12w4Imm12b0w12
    {
        private readonly uint _value;
        public InstCondb28w4Sb20w1Rdb12w4Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint Rd => (_value >> 12) & 0xF;
        public uint S => (_value >> 20) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRdb24w3Imm8b16w8
    {
        private readonly uint _value;
        public InstRdb24w3Imm8b16w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 16) & 0xFF;
        public uint Rd => (_value >> 24) & 0x7;
    }

    struct InstImm7b16w7
    {
        private readonly uint _value;
        public InstImm7b16w7(uint value) => _value = value;
        public uint Imm7 => (_value >> 16) & 0x7F;
    }

    struct InstIb26w1Sb20w1Imm3b12w3Rdb8w4Imm8b0w8
    {
        private readonly uint _value;
        public InstIb26w1Sb20w1Imm3b12w3Rdb8w4Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Imm3 => (_value >> 12) & 0x7;
        public uint S => (_value >> 20) & 0x1;
        public uint I => (_value >> 26) & 0x1;
    }

    struct InstIb26w1Imm3b12w3Rdb8w4Imm8b0w8
    {
        private readonly uint _value;
        public InstIb26w1Imm3b12w3Rdb8w4Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Imm3 => (_value >> 12) & 0x7;
        public uint I => (_value >> 26) & 0x1;
    }

    struct InstCondb28w4Sb20w1Rdb12w4Imm5b7w5Stypeb5w2Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Sb20w1Rdb12w4Imm5b7w5Stypeb5w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Stype => (_value >> 5) & 0x3;
        public uint Imm5 => (_value >> 7) & 0x1F;
        public uint Rd => (_value >> 12) & 0xF;
        public uint S => (_value >> 20) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstDmb23w1Rdmb16w3
    {
        private readonly uint _value;
        public InstDmb23w1Rdmb16w3(uint value) => _value = value;
        public uint Rdm => (_value >> 16) & 0x7;
        public uint Dm => (_value >> 23) & 0x1;
    }

    struct InstRmb19w4
    {
        private readonly uint _value;
        public InstRmb19w4(uint value) => _value = value;
        public uint Rm => (_value >> 19) & 0xF;
    }

    struct InstSb20w1Imm3b12w3Rdb8w4Imm2b6w2Stypeb4w2Rmb0w4
    {
        private readonly uint _value;
        public InstSb20w1Imm3b12w3Rdb8w4Imm2b6w2Stypeb4w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Stype => (_value >> 4) & 0x3;
        public uint Imm2 => (_value >> 6) & 0x3;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Imm3 => (_value >> 12) & 0x7;
        public uint S => (_value >> 20) & 0x1;
    }

    struct InstCondb28w4Rdb12w4Imm12b0w12
    {
        private readonly uint _value;
        public InstCondb28w4Rdb12w4Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint Rd => (_value >> 12) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstDb22w1Sizeb18w2Vdb12w4Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Sizeb18w2Vdb12w4Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Size => (_value >> 18) & 0x3;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstCondb28w4Imm24b0w24
    {
        private readonly uint _value;
        public InstCondb28w4Imm24b0w24(uint value) => _value = value;
        public uint Imm24 => (_value >> 0) & 0xFFFFFF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstCondb24w4Imm8b16w8
    {
        private readonly uint _value;
        public InstCondb24w4Imm8b16w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 16) & 0xFF;
        public uint Cond => (_value >> 24) & 0xF;
    }

    struct InstImm11b16w11
    {
        private readonly uint _value;
        public InstImm11b16w11(uint value) => _value = value;
        public uint Imm11 => (_value >> 16) & 0x7FF;
    }

    struct InstSb26w1Condb22w4Imm6b16w6J1b13w1J2b11w1Imm11b0w11
    {
        private readonly uint _value;
        public InstSb26w1Condb22w4Imm6b16w6J1b13w1J2b11w1Imm11b0w11(uint value) => _value = value;
        public uint Imm11 => (_value >> 0) & 0x7FF;
        public uint J2 => (_value >> 11) & 0x1;
        public uint J1 => (_value >> 13) & 0x1;
        public uint Imm6 => (_value >> 16) & 0x3F;
        public uint Cond => (_value >> 22) & 0xF;
        public uint S => (_value >> 26) & 0x1;
    }

    struct InstSb26w1Imm10b16w10J1b13w1J2b11w1Imm11b0w11
    {
        private readonly uint _value;
        public InstSb26w1Imm10b16w10J1b13w1J2b11w1Imm11b0w11(uint value) => _value = value;
        public uint Imm11 => (_value >> 0) & 0x7FF;
        public uint J2 => (_value >> 11) & 0x1;
        public uint J1 => (_value >> 13) & 0x1;
        public uint Imm10 => (_value >> 16) & 0x3FF;
        public uint S => (_value >> 26) & 0x1;
    }

    struct InstCondb28w4Msbb16w5Rdb12w4Lsbb7w5
    {
        private readonly uint _value;
        public InstCondb28w4Msbb16w5Rdb12w4Lsbb7w5(uint value) => _value = value;
        public uint Lsb => (_value >> 7) & 0x1F;
        public uint Rd => (_value >> 12) & 0xF;
        public uint Msb => (_value >> 16) & 0x1F;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstImm3b12w3Rdb8w4Imm2b6w2Msbb0w5
    {
        private readonly uint _value;
        public InstImm3b12w3Rdb8w4Imm2b6w2Msbb0w5(uint value) => _value = value;
        public uint Msb => (_value >> 0) & 0x1F;
        public uint Imm2 => (_value >> 6) & 0x3;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Imm3 => (_value >> 12) & 0x7;
    }

    struct InstCondb28w4Msbb16w5Rdb12w4Lsbb7w5Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Msbb16w5Rdb12w4Lsbb7w5Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint Lsb => (_value >> 7) & 0x1F;
        public uint Rd => (_value >> 12) & 0xF;
        public uint Msb => (_value >> 16) & 0x1F;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Imm3b12w3Rdb8w4Imm2b6w2Msbb0w5
    {
        private readonly uint _value;
        public InstRnb16w4Imm3b12w3Rdb8w4Imm2b6w2Msbb0w5(uint value) => _value = value;
        public uint Msb => (_value >> 0) & 0x1F;
        public uint Imm2 => (_value >> 6) & 0x3;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Imm3 => (_value >> 12) & 0x7;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Imm12b8w12Imm4b0w4
    {
        private readonly uint _value;
        public InstCondb28w4Imm12b8w12Imm4b0w4(uint value) => _value = value;
        public uint Imm4 => (_value >> 0) & 0xF;
        public uint Imm12 => (_value >> 8) & 0xFFF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstImm8b16w8
    {
        private readonly uint _value;
        public InstImm8b16w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 16) & 0xFF;
    }

    struct InstCondb28w4Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstHb24w1Imm24b0w24
    {
        private readonly uint _value;
        public InstHb24w1Imm24b0w24(uint value) => _value = value;
        public uint Imm24 => (_value >> 0) & 0xFFFFFF;
        public uint H => (_value >> 24) & 0x1;
    }

    struct InstSb26w1Imm10hb16w10J1b13w1J2b11w1Imm10lb1w10Hb0w1
    {
        private readonly uint _value;
        public InstSb26w1Imm10hb16w10J1b13w1J2b11w1Imm10lb1w10Hb0w1(uint value) => _value = value;
        public uint H => (_value >> 0) & 0x1;
        public uint Imm10l => (_value >> 1) & 0x3FF;
        public uint J2 => (_value >> 11) & 0x1;
        public uint J1 => (_value >> 13) & 0x1;
        public uint Imm10h => (_value >> 16) & 0x3FF;
        public uint S => (_value >> 26) & 0x1;
    }

    struct InstRmb16w4
    {
        private readonly uint _value;
        public InstRmb16w4(uint value) => _value = value;
        public uint Rm => (_value >> 16) & 0xF;
    }

    struct InstOpb27w1Ib25w1Imm5b19w5Rnb16w3
    {
        private readonly uint _value;
        public InstOpb27w1Ib25w1Imm5b19w5Rnb16w3(uint value) => _value = value;
        public uint Rn => (_value >> 16) & 0x7;
        public uint Imm5 => (_value >> 19) & 0x1F;
        public uint I => (_value >> 25) & 0x1;
        public uint Op => (_value >> 27) & 0x1;
    }

    struct InstCondb28w4
    {
        private readonly uint _value;
        public InstCondb28w4(uint value) => _value = value;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct Inst
    {
        private readonly uint _value;
        public Inst(uint value) => _value = value;
    }

    struct InstCondb28w4Rdb12w4Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rdb12w4Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Rd => (_value >> 12) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rdb8w4Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rdb8w4Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Rnb16w4Imm12b0w12
    {
        private readonly uint _value;
        public InstCondb28w4Rnb16w4Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstIb26w1Rnb16w4Imm3b12w3Imm8b0w8
    {
        private readonly uint _value;
        public InstIb26w1Rnb16w4Imm3b12w3Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Imm3 => (_value >> 12) & 0x7;
        public uint Rn => (_value >> 16) & 0xF;
        public uint I => (_value >> 26) & 0x1;
    }

    struct InstCondb28w4Rnb16w4Imm5b7w5Stypeb5w2Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rnb16w4Imm5b7w5Stypeb5w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Stype => (_value >> 5) & 0x3;
        public uint Imm5 => (_value >> 7) & 0x1F;
        public uint Rn => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRmb19w3Rnb16w3
    {
        private readonly uint _value;
        public InstRmb19w3Rnb16w3(uint value) => _value = value;
        public uint Rn => (_value >> 16) & 0x7;
        public uint Rm => (_value >> 19) & 0x7;
    }

    struct InstRnb16w4Imm3b12w3Imm2b6w2Stypeb4w2Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Imm3b12w3Imm2b6w2Stypeb4w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Stype => (_value >> 4) & 0x3;
        public uint Imm2 => (_value >> 6) & 0x3;
        public uint Imm3 => (_value >> 12) & 0x7;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Rnb16w4Rsb8w4Stypeb5w2Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rnb16w4Rsb8w4Stypeb5w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Stype => (_value >> 5) & 0x3;
        public uint Rs => (_value >> 8) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb24w3Imm8b16w8
    {
        private readonly uint _value;
        public InstRnb24w3Imm8b16w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 16) & 0xFF;
        public uint Rn => (_value >> 24) & 0x7;
    }

    struct InstNb23w1Rmb19w4Rnb16w3
    {
        private readonly uint _value;
        public InstNb23w1Rmb19w4Rnb16w3(uint value) => _value = value;
        public uint Rn => (_value >> 16) & 0x7;
        public uint Rm => (_value >> 19) & 0xF;
        public uint N => (_value >> 23) & 0x1;
    }

    struct InstImodb18w2Mb17w1Ab8w1Ib7w1Fb6w1Modeb0w5
    {
        private readonly uint _value;
        public InstImodb18w2Mb17w1Ab8w1Ib7w1Fb6w1Modeb0w5(uint value) => _value = value;
        public uint Mode => (_value >> 0) & 0x1F;
        public uint F => (_value >> 6) & 0x1;
        public uint I => (_value >> 7) & 0x1;
        public uint A => (_value >> 8) & 0x1;
        public uint M => (_value >> 17) & 0x1;
        public uint Imod => (_value >> 18) & 0x3;
    }

    struct InstImb20w1Ab18w1Ib17w1Fb16w1
    {
        private readonly uint _value;
        public InstImb20w1Ab18w1Ib17w1Fb16w1(uint value) => _value = value;
        public uint F => (_value >> 16) & 0x1;
        public uint I => (_value >> 17) & 0x1;
        public uint A => (_value >> 18) & 0x1;
        public uint Im => (_value >> 20) & 0x1;
    }

    struct InstImodb9w2Mb8w1Ab7w1Ib6w1Fb5w1Modeb0w5
    {
        private readonly uint _value;
        public InstImodb9w2Mb8w1Ab7w1Ib6w1Fb5w1Modeb0w5(uint value) => _value = value;
        public uint Mode => (_value >> 0) & 0x1F;
        public uint F => (_value >> 5) & 0x1;
        public uint I => (_value >> 6) & 0x1;
        public uint A => (_value >> 7) & 0x1;
        public uint M => (_value >> 8) & 0x1;
        public uint Imod => (_value >> 9) & 0x3;
    }

    struct InstCondb28w4Szb21w2Rnb16w4Rdb12w4Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Szb21w2Rnb16w4Rdb12w4Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Rd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint Sz => (_value >> 21) & 0x3;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rdb8w4Szb4w2Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rdb8w4Szb4w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Sz => (_value >> 4) & 0x3;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Optionb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Optionb0w4(uint value) => _value = value;
        public uint Option => (_value >> 0) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstOptionb0w4
    {
        private readonly uint _value;
        public InstOptionb0w4(uint value) => _value = value;
        public uint Option => (_value >> 0) & 0xF;
    }

    struct InstCondb28w4Pb24w1Ub23w1Db22w1Wb21w1Rnb16w4Vdb12w4Imm871b1w7
    {
        private readonly uint _value;
        public InstCondb28w4Pb24w1Ub23w1Db22w1Wb21w1Rnb16w4Vdb12w4Imm871b1w7(uint value) => _value = value;
        public uint Imm871 => (_value >> 1) & 0x7F;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint P => (_value >> 24) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstPb24w1Ub23w1Db22w1Wb21w1Rnb16w4Vdb12w4Imm871b1w7
    {
        private readonly uint _value;
        public InstPb24w1Ub23w1Db22w1Wb21w1Rnb16w4Vdb12w4Imm871b1w7(uint value) => _value = value;
        public uint Imm871 => (_value >> 1) & 0x7F;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint P => (_value >> 24) & 0x1;
    }

    struct InstImm6b16w6
    {
        private readonly uint _value;
        public InstImm6b16w6(uint value) => _value = value;
        public uint Imm6 => (_value >> 16) & 0x3F;
    }

    struct InstFirstcondb20w4Maskb16w4
    {
        private readonly uint _value;
        public InstFirstcondb20w4Maskb16w4(uint value) => _value = value;
        public uint Mask => (_value >> 16) & 0xF;
        public uint Firstcond => (_value >> 20) & 0xF;
    }

    struct InstCondb28w4Rnb16w4Rtb12w4
    {
        private readonly uint _value;
        public InstCondb28w4Rnb16w4Rtb12w4(uint value) => _value = value;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rtb12w4
    {
        private readonly uint _value;
        public InstRnb16w4Rtb12w4(uint value) => _value = value;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstRnb16w4Rtb12w4Rt2b8w4
    {
        private readonly uint _value;
        public InstRnb16w4Rtb12w4Rt2b8w4(uint value) => _value = value;
        public uint Rt2 => (_value >> 8) & 0xF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Pb24w1Ub23w1Wb21w1Rnb16w4Imm8b0w8
    {
        private readonly uint _value;
        public InstCondb28w4Pb24w1Ub23w1Wb21w1Rnb16w4Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint P => (_value >> 24) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstPb24w1Ub23w1Wb21w1Rnb16w4Imm8b0w8
    {
        private readonly uint _value;
        public InstPb24w1Ub23w1Wb21w1Rnb16w4Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint P => (_value >> 24) & 0x1;
    }

    struct InstCondb28w4Pb24w1Ub23w1Wb21w1Imm8b0w8
    {
        private readonly uint _value;
        public InstCondb28w4Pb24w1Ub23w1Wb21w1Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint W => (_value >> 21) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint P => (_value >> 24) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstPb24w1Ub23w1Wb21w1Imm8b0w8
    {
        private readonly uint _value;
        public InstPb24w1Ub23w1Wb21w1Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint W => (_value >> 21) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint P => (_value >> 24) & 0x1;
    }

    struct InstCondb28w4Wb21w1Rnb16w4RegisterListb0w16
    {
        private readonly uint _value;
        public InstCondb28w4Wb21w1Rnb16w4RegisterListb0w16(uint value) => _value = value;
        public uint RegisterList => (_value >> 0) & 0xFFFF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb24w3RegisterListb16w8
    {
        private readonly uint _value;
        public InstRnb24w3RegisterListb16w8(uint value) => _value = value;
        public uint RegisterList => (_value >> 16) & 0xFF;
        public uint Rn => (_value >> 24) & 0x7;
    }

    struct InstWb21w1Rnb16w4Pb15w1Mb14w1RegisterListb0w14
    {
        private readonly uint _value;
        public InstWb21w1Rnb16w4Pb15w1Mb14w1RegisterListb0w14(uint value) => _value = value;
        public uint RegisterList => (_value >> 0) & 0x3FFF;
        public uint M => (_value >> 14) & 0x1;
        public uint P => (_value >> 15) & 0x1;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
    }

    struct InstCondb28w4Ub23w1Rnb16w4Rtb12w4Imm12b0w12
    {
        private readonly uint _value;
        public InstCondb28w4Ub23w1Rnb16w4Rtb12w4Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint U => (_value >> 23) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstCondb28w4Ub23w1Rnb16w4Rtb12w4Imm5b7w5Stypeb5w2Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Ub23w1Rnb16w4Rtb12w4Imm5b7w5Stypeb5w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Stype => (_value >> 5) & 0x3;
        public uint Imm5 => (_value >> 7) & 0x1F;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint U => (_value >> 23) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rtb12w4Imm8b0w8
    {
        private readonly uint _value;
        public InstRnb16w4Rtb12w4Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Pb24w1Ub23w1Wb21w1Rnb16w4Rtb12w4Imm12b0w12
    {
        private readonly uint _value;
        public InstCondb28w4Pb24w1Ub23w1Wb21w1Rnb16w4Rtb12w4Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint P => (_value >> 24) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstImm5b22w5Rnb19w3Rtb16w3
    {
        private readonly uint _value;
        public InstImm5b22w5Rnb19w3Rtb16w3(uint value) => _value = value;
        public uint Rt => (_value >> 16) & 0x7;
        public uint Rn => (_value >> 19) & 0x7;
        public uint Imm5 => (_value >> 22) & 0x1F;
    }

    struct InstRnb16w4Rtb12w4Imm12b0w12
    {
        private readonly uint _value;
        public InstRnb16w4Rtb12w4Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstRnb16w4Rtb12w4Pb10w1Ub9w1Wb8w1Imm8b0w8
    {
        private readonly uint _value;
        public InstRnb16w4Rtb12w4Pb10w1Ub9w1Wb8w1Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint W => (_value >> 8) & 0x1;
        public uint U => (_value >> 9) & 0x1;
        public uint P => (_value >> 10) & 0x1;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Pb24w1Ub23w1Wb21w1Rtb12w4Imm12b0w12
    {
        private readonly uint _value;
        public InstCondb28w4Pb24w1Ub23w1Wb21w1Rtb12w4Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint W => (_value >> 21) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint P => (_value >> 24) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstUb23w1Rtb12w4Imm12b0w12
    {
        private readonly uint _value;
        public InstUb23w1Rtb12w4Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint U => (_value >> 23) & 0x1;
    }

    struct InstCondb28w4Pb24w1Ub23w1Wb21w1Rnb16w4Rtb12w4Imm5b7w5Stypeb5w2Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Pb24w1Ub23w1Wb21w1Rnb16w4Rtb12w4Imm5b7w5Stypeb5w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Stype => (_value >> 5) & 0x3;
        public uint Imm5 => (_value >> 7) & 0x1F;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint P => (_value >> 24) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRmb22w3Rnb19w3Rtb16w3
    {
        private readonly uint _value;
        public InstRmb22w3Rnb19w3Rtb16w3(uint value) => _value = value;
        public uint Rt => (_value >> 16) & 0x7;
        public uint Rn => (_value >> 19) & 0x7;
        public uint Rm => (_value >> 22) & 0x7;
    }

    struct InstRnb16w4Rtb12w4Imm2b4w2Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rtb12w4Imm2b4w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Imm2 => (_value >> 4) & 0x3;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Pb24w1Ub23w1Wb21w1Rnb16w4Rtb12w4Imm4hb8w4Imm4lb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Pb24w1Ub23w1Wb21w1Rnb16w4Rtb12w4Imm4hb8w4Imm4lb0w4(uint value) => _value = value;
        public uint Imm4l => (_value >> 0) & 0xF;
        public uint Imm4h => (_value >> 8) & 0xF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint P => (_value >> 24) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstPb24w1Ub23w1Wb21w1Rnb16w4Rtb12w4Rt2b8w4Imm8b0w8
    {
        private readonly uint _value;
        public InstPb24w1Ub23w1Wb21w1Rnb16w4Rtb12w4Rt2b8w4Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Rt2 => (_value >> 8) & 0xF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint P => (_value >> 24) & 0x1;
    }

    struct InstCondb28w4Ub23w1Rtb12w4Imm4hb8w4Imm4lb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Ub23w1Rtb12w4Imm4hb8w4Imm4lb0w4(uint value) => _value = value;
        public uint Imm4l => (_value >> 0) & 0xF;
        public uint Imm4h => (_value >> 8) & 0xF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint U => (_value >> 23) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstPb24w1Ub23w1Wb21w1Rtb12w4Rt2b8w4Imm8b0w8
    {
        private readonly uint _value;
        public InstPb24w1Ub23w1Wb21w1Rtb12w4Rt2b8w4Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Rt2 => (_value >> 8) & 0xF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint W => (_value >> 21) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint P => (_value >> 24) & 0x1;
    }

    struct InstCondb28w4Pb24w1Ub23w1Wb21w1Rnb16w4Rtb12w4Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Pb24w1Ub23w1Wb21w1Rnb16w4Rtb12w4Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint P => (_value >> 24) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstCondb28w4Ub23w1Rnb16w4Rtb12w4Imm4hb8w4Imm4lb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Ub23w1Rnb16w4Rtb12w4Imm4hb8w4Imm4lb0w4(uint value) => _value = value;
        public uint Imm4l => (_value >> 0) & 0xF;
        public uint Imm4h => (_value >> 8) & 0xF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint U => (_value >> 23) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstCondb28w4Ub23w1Rnb16w4Rtb12w4Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Ub23w1Rnb16w4Rtb12w4Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint U => (_value >> 23) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstCondb28w4Pb24w1Ub23w1Wb21w1Rtb12w4Imm4hb8w4Imm4lb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Pb24w1Ub23w1Wb21w1Rtb12w4Imm4hb8w4Imm4lb0w4(uint value) => _value = value;
        public uint Imm4l => (_value >> 0) & 0xF;
        public uint Imm4h => (_value >> 8) & 0xF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint W => (_value >> 21) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint P => (_value >> 24) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRtb24w3Imm8b16w8
    {
        private readonly uint _value;
        public InstRtb24w3Imm8b16w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 16) & 0xFF;
        public uint Rt => (_value >> 24) & 0x7;
    }

    struct InstCondb28w4Opc1b21w3Crnb16w4Rtb12w4Coproc0b8w1Opc2b5w3Crmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Opc1b21w3Crnb16w4Rtb12w4Coproc0b8w1Opc2b5w3Crmb0w4(uint value) => _value = value;
        public uint Crm => (_value >> 0) & 0xF;
        public uint Opc2 => (_value >> 5) & 0x7;
        public uint Coproc0 => (_value >> 8) & 0x1;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Crn => (_value >> 16) & 0xF;
        public uint Opc1 => (_value >> 21) & 0x7;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstOpc1b21w3Crnb16w4Rtb12w4Coproc0b8w1Opc2b5w3Crmb0w4
    {
        private readonly uint _value;
        public InstOpc1b21w3Crnb16w4Rtb12w4Coproc0b8w1Opc2b5w3Crmb0w4(uint value) => _value = value;
        public uint Crm => (_value >> 0) & 0xF;
        public uint Opc2 => (_value >> 5) & 0x7;
        public uint Coproc0 => (_value >> 8) & 0x1;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Crn => (_value >> 16) & 0xF;
        public uint Opc1 => (_value >> 21) & 0x7;
    }

    struct InstCondb28w4Rt2b16w4Rtb12w4Coproc0b8w1Opc1b4w4Crmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rt2b16w4Rtb12w4Coproc0b8w1Opc1b4w4Crmb0w4(uint value) => _value = value;
        public uint Crm => (_value >> 0) & 0xF;
        public uint Opc1 => (_value >> 4) & 0xF;
        public uint Coproc0 => (_value >> 8) & 0x1;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rt2 => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRt2b16w4Rtb12w4Coproc0b8w1Opc1b4w4Crmb0w4
    {
        private readonly uint _value;
        public InstRt2b16w4Rtb12w4Coproc0b8w1Opc1b4w4Crmb0w4(uint value) => _value = value;
        public uint Crm => (_value >> 0) & 0xF;
        public uint Opc1 => (_value >> 4) & 0xF;
        public uint Coproc0 => (_value >> 8) & 0x1;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rt2 => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Sb20w1Rdb16w4Rab12w4Rmb8w4Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Sb20w1Rdb16w4Rab12w4Rmb8w4Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint Rm => (_value >> 8) & 0xF;
        public uint Ra => (_value >> 12) & 0xF;
        public uint Rd => (_value >> 16) & 0xF;
        public uint S => (_value >> 20) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rab12w4Rdb8w4Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rab12w4Rdb8w4Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Ra => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Rdb16w4Rab12w4Rmb8w4Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rdb16w4Rab12w4Rmb8w4Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint Rm => (_value >> 8) & 0xF;
        public uint Ra => (_value >> 12) & 0xF;
        public uint Rd => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstCondb28w4Imm4b16w4Rdb12w4Imm12b0w12
    {
        private readonly uint _value;
        public InstCondb28w4Imm4b16w4Rdb12w4Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint Rd => (_value >> 12) & 0xF;
        public uint Imm4 => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstIb26w1Imm4b16w4Imm3b12w3Rdb8w4Imm8b0w8
    {
        private readonly uint _value;
        public InstIb26w1Imm4b16w4Imm3b12w3Rdb8w4Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Imm3 => (_value >> 12) & 0x7;
        public uint Imm4 => (_value >> 16) & 0xF;
        public uint I => (_value >> 26) & 0x1;
    }

    struct InstDb23w1Rmb19w4Rdb16w3
    {
        private readonly uint _value;
        public InstDb23w1Rmb19w4Rdb16w3(uint value) => _value = value;
        public uint Rd => (_value >> 16) & 0x7;
        public uint Rm => (_value >> 19) & 0xF;
        public uint D => (_value >> 23) & 0x1;
    }

    struct InstOpb27w2Imm5b22w5Rmb19w3Rdb16w3
    {
        private readonly uint _value;
        public InstOpb27w2Imm5b22w5Rmb19w3Rdb16w3(uint value) => _value = value;
        public uint Rd => (_value >> 16) & 0x7;
        public uint Rm => (_value >> 19) & 0x7;
        public uint Imm5 => (_value >> 22) & 0x1F;
        public uint Op => (_value >> 27) & 0x3;
    }

    struct InstCondb28w4Sb20w1Rdb12w4Rsb8w4Stypeb5w2Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Sb20w1Rdb12w4Rsb8w4Stypeb5w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Stype => (_value >> 5) & 0x3;
        public uint Rs => (_value >> 8) & 0xF;
        public uint Rd => (_value >> 12) & 0xF;
        public uint S => (_value >> 20) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRsb19w3Rdmb16w3
    {
        private readonly uint _value;
        public InstRsb19w3Rdmb16w3(uint value) => _value = value;
        public uint Rdm => (_value >> 16) & 0x7;
        public uint Rs => (_value >> 19) & 0x7;
    }

    struct InstStypeb21w2Sb20w1Rmb16w4Rdb8w4Rsb0w4
    {
        private readonly uint _value;
        public InstStypeb21w2Sb20w1Rmb16w4Rdb8w4Rsb0w4(uint value) => _value = value;
        public uint Rs => (_value >> 0) & 0xF;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Rm => (_value >> 16) & 0xF;
        public uint S => (_value >> 20) & 0x1;
        public uint Stype => (_value >> 21) & 0x3;
    }

    struct InstCondb28w4Rb22w1Rdb12w4
    {
        private readonly uint _value;
        public InstCondb28w4Rb22w1Rdb12w4(uint value) => _value = value;
        public uint Rd => (_value >> 12) & 0xF;
        public uint R => (_value >> 22) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRb20w1Rdb8w4
    {
        private readonly uint _value;
        public InstRb20w1Rdb8w4(uint value) => _value = value;
        public uint Rd => (_value >> 8) & 0xF;
        public uint R => (_value >> 20) & 0x1;
    }

    struct InstCondb28w4Rb22w1M1b16w4Rdb12w4Mb8w1
    {
        private readonly uint _value;
        public InstCondb28w4Rb22w1M1b16w4Rdb12w4Mb8w1(uint value) => _value = value;
        public uint M => (_value >> 8) & 0x1;
        public uint Rd => (_value >> 12) & 0xF;
        public uint M1 => (_value >> 16) & 0xF;
        public uint R => (_value >> 22) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRb20w1M1b16w4Rdb8w4Mb4w1
    {
        private readonly uint _value;
        public InstRb20w1M1b16w4Rdb8w4Mb4w1(uint value) => _value = value;
        public uint M => (_value >> 4) & 0x1;
        public uint Rd => (_value >> 8) & 0xF;
        public uint M1 => (_value >> 16) & 0xF;
        public uint R => (_value >> 20) & 0x1;
    }

    struct InstCondb28w4Rb22w1M1b16w4Mb8w1Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rb22w1M1b16w4Mb8w1Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint M => (_value >> 8) & 0x1;
        public uint M1 => (_value >> 16) & 0xF;
        public uint R => (_value >> 22) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRb20w1Rnb16w4M1b8w4Mb4w1
    {
        private readonly uint _value;
        public InstRb20w1Rnb16w4M1b8w4Mb4w1(uint value) => _value = value;
        public uint M => (_value >> 4) & 0x1;
        public uint M1 => (_value >> 8) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint R => (_value >> 20) & 0x1;
    }

    struct InstCondb28w4Rb22w1Maskb16w4Imm12b0w12
    {
        private readonly uint _value;
        public InstCondb28w4Rb22w1Maskb16w4Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint Mask => (_value >> 16) & 0xF;
        public uint R => (_value >> 22) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstCondb28w4Rb22w1Maskb16w4Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rb22w1Maskb16w4Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint Mask => (_value >> 16) & 0xF;
        public uint R => (_value >> 22) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRb20w1Rnb16w4Maskb8w4
    {
        private readonly uint _value;
        public InstRb20w1Rnb16w4Maskb8w4(uint value) => _value = value;
        public uint Mask => (_value >> 8) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint R => (_value >> 20) & 0x1;
    }

    struct InstCondb28w4Sb20w1Rdb16w4Rmb8w4Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Sb20w1Rdb16w4Rmb8w4Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint Rm => (_value >> 8) & 0xF;
        public uint Rd => (_value >> 16) & 0xF;
        public uint S => (_value >> 20) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb19w3Rdmb16w3
    {
        private readonly uint _value;
        public InstRnb19w3Rdmb16w3(uint value) => _value = value;
        public uint Rdm => (_value >> 16) & 0x7;
        public uint Rn => (_value >> 19) & 0x7;
    }

    struct InstRmb19w3Rdb16w3
    {
        private readonly uint _value;
        public InstRmb19w3Rdb16w3(uint value) => _value = value;
        public uint Rd => (_value >> 16) & 0x7;
        public uint Rm => (_value >> 19) & 0x7;
    }

    struct InstCondb28w4Rnb16w4Rdb12w4Imm5b7w5Tbb6w1Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rnb16w4Rdb12w4Imm5b7w5Tbb6w1Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Tb => (_value >> 6) & 0x1;
        public uint Imm5 => (_value >> 7) & 0x1F;
        public uint Rd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Imm3b12w3Rdb8w4Imm2b6w2Tbb5w1Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Imm3b12w3Rdb8w4Imm2b6w2Tbb5w1Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Tb => (_value >> 5) & 0x1;
        public uint Imm2 => (_value >> 6) & 0x3;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Imm3 => (_value >> 12) & 0x7;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstUb23w1Rb22w1Rnb16w4Imm12b0w12
    {
        private readonly uint _value;
        public InstUb23w1Rb22w1Rnb16w4Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint R => (_value >> 22) & 0x1;
        public uint U => (_value >> 23) & 0x1;
    }

    struct InstWb21w1Rnb16w4Imm12b0w12
    {
        private readonly uint _value;
        public InstWb21w1Rnb16w4Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
    }

    struct InstWb21w1Rnb16w4Imm8b0w8
    {
        private readonly uint _value;
        public InstWb21w1Rnb16w4Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
    }

    struct InstUb23w1Imm12b0w12
    {
        private readonly uint _value;
        public InstUb23w1Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint U => (_value >> 23) & 0x1;
    }

    struct InstUb23w1Rb22w1Rnb16w4Imm5b7w5Stypeb5w2Rmb0w4
    {
        private readonly uint _value;
        public InstUb23w1Rb22w1Rnb16w4Imm5b7w5Stypeb5w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Stype => (_value >> 5) & 0x3;
        public uint Imm5 => (_value >> 7) & 0x1F;
        public uint Rn => (_value >> 16) & 0xF;
        public uint R => (_value >> 22) & 0x1;
        public uint U => (_value >> 23) & 0x1;
    }

    struct InstWb21w1Rnb16w4Imm2b4w2Rmb0w4
    {
        private readonly uint _value;
        public InstWb21w1Rnb16w4Imm2b4w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Imm2 => (_value >> 4) & 0x3;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
    }

    struct InstUb23w1Rnb16w4Imm12b0w12
    {
        private readonly uint _value;
        public InstUb23w1Rnb16w4Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint U => (_value >> 23) & 0x1;
    }

    struct InstRnb16w4Imm12b0w12
    {
        private readonly uint _value;
        public InstRnb16w4Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstRnb16w4Imm8b0w8
    {
        private readonly uint _value;
        public InstRnb16w4Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstUb23w1Rnb16w4Imm5b7w5Stypeb5w2Rmb0w4
    {
        private readonly uint _value;
        public InstUb23w1Rnb16w4Imm5b7w5Stypeb5w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Stype => (_value >> 5) & 0x3;
        public uint Imm5 => (_value >> 7) & 0x1F;
        public uint Rn => (_value >> 16) & 0xF;
        public uint U => (_value >> 23) & 0x1;
    }

    struct InstRnb16w4Imm2b4w2Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Imm2b4w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Imm2 => (_value >> 4) & 0x3;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstPb24w1RegisterListb16w8
    {
        private readonly uint _value;
        public InstPb24w1RegisterListb16w8(uint value) => _value = value;
        public uint RegisterList => (_value >> 16) & 0xFF;
        public uint P => (_value >> 24) & 0x1;
    }

    struct InstMb24w1RegisterListb16w8
    {
        private readonly uint _value;
        public InstMb24w1RegisterListb16w8(uint value) => _value = value;
        public uint RegisterList => (_value >> 16) & 0xFF;
        public uint M => (_value >> 24) & 0x1;
    }

    struct InstCondb28w4Rnb16w4Rdb12w4Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rnb16w4Rdb12w4Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Rd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb19w3Rdb16w3
    {
        private readonly uint _value;
        public InstRnb19w3Rdb16w3(uint value) => _value = value;
        public uint Rd => (_value >> 16) & 0x7;
        public uint Rn => (_value >> 19) & 0x7;
    }

    struct InstCondb28w4Widthm1b16w5Rdb12w4Lsbb7w5Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Widthm1b16w5Rdb12w4Lsbb7w5Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint Lsb => (_value >> 7) & 0x1F;
        public uint Rd => (_value >> 12) & 0xF;
        public uint Widthm1 => (_value >> 16) & 0x1F;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Imm3b12w3Rdb8w4Imm2b6w2Widthm1b0w5
    {
        private readonly uint _value;
        public InstRnb16w4Imm3b12w3Rdb8w4Imm2b6w2Widthm1b0w5(uint value) => _value = value;
        public uint Widthm1 => (_value >> 0) & 0x1F;
        public uint Imm2 => (_value >> 6) & 0x3;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Imm3 => (_value >> 12) & 0x7;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Rdb16w4Rmb8w4Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rdb16w4Rmb8w4Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint Rm => (_value >> 8) & 0xF;
        public uint Rd => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstEb9w1
    {
        private readonly uint _value;
        public InstEb9w1(uint value) => _value = value;
        public uint E => (_value >> 9) & 0x1;
    }

    struct InstEb19w1
    {
        private readonly uint _value;
        public InstEb19w1(uint value) => _value = value;
        public uint E => (_value >> 19) & 0x1;
    }

    struct InstImm1b9w1
    {
        private readonly uint _value;
        public InstImm1b9w1(uint value) => _value = value;
        public uint Imm1 => (_value >> 9) & 0x1;
    }

    struct InstImm1b19w1
    {
        private readonly uint _value;
        public InstImm1b19w1(uint value) => _value = value;
        public uint Imm1 => (_value >> 19) & 0x1;
    }

    struct InstDb22w1Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstCondb28w4Rdb16w4Rab12w4Rmb8w4Mb6w1Nb5w1Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rdb16w4Rab12w4Rmb8w4Mb6w1Nb5w1Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint N => (_value >> 5) & 0x1;
        public uint M => (_value >> 6) & 0x1;
        public uint Rm => (_value >> 8) & 0xF;
        public uint Ra => (_value >> 12) & 0xF;
        public uint Rd => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rab12w4Rdb8w4Nb5w1Mb4w1Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rab12w4Rdb8w4Nb5w1Mb4w1Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint M => (_value >> 4) & 0x1;
        public uint N => (_value >> 5) & 0x1;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Ra => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Rdb16w4Rab12w4Rmb8w4Mb5w1Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rdb16w4Rab12w4Rmb8w4Mb5w1Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Rm => (_value >> 8) & 0xF;
        public uint Ra => (_value >> 12) & 0xF;
        public uint Rd => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rab12w4Rdb8w4Mb4w1Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rab12w4Rdb8w4Mb4w1Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint M => (_value >> 4) & 0x1;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Ra => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Sb20w1Rdhib16w4Rdlob12w4Rmb8w4Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Sb20w1Rdhib16w4Rdlob12w4Rmb8w4Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint Rm => (_value >> 8) & 0xF;
        public uint Rdlo => (_value >> 12) & 0xF;
        public uint Rdhi => (_value >> 16) & 0xF;
        public uint S => (_value >> 20) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rdlob12w4Rdhib8w4Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rdlob12w4Rdhib8w4Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Rdhi => (_value >> 8) & 0xF;
        public uint Rdlo => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Rdhib16w4Rdlob12w4Rmb8w4Mb6w1Nb5w1Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rdhib16w4Rdlob12w4Rmb8w4Mb6w1Nb5w1Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint N => (_value >> 5) & 0x1;
        public uint M => (_value >> 6) & 0x1;
        public uint Rm => (_value >> 8) & 0xF;
        public uint Rdlo => (_value >> 12) & 0xF;
        public uint Rdhi => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rdlob12w4Rdhib8w4Nb5w1Mb4w1Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rdlob12w4Rdhib8w4Nb5w1Mb4w1Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint M => (_value >> 4) & 0x1;
        public uint N => (_value >> 5) & 0x1;
        public uint Rdhi => (_value >> 8) & 0xF;
        public uint Rdlo => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Rdhib16w4Rdlob12w4Rmb8w4Mb5w1Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rdhib16w4Rdlob12w4Rmb8w4Mb5w1Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Rm => (_value >> 8) & 0xF;
        public uint Rdlo => (_value >> 12) & 0xF;
        public uint Rdhi => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rdlob12w4Rdhib8w4Mb4w1Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rdlob12w4Rdhib8w4Mb4w1Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint M => (_value >> 4) & 0x1;
        public uint Rdhi => (_value >> 8) & 0xF;
        public uint Rdlo => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Rdb16w4Rab12w4Rmb8w4Mb6w1Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rdb16w4Rab12w4Rmb8w4Mb6w1Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint M => (_value >> 6) & 0x1;
        public uint Rm => (_value >> 8) & 0xF;
        public uint Ra => (_value >> 12) & 0xF;
        public uint Rd => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstCondb28w4Rdb16w4Rab12w4Rmb8w4Rb5w1Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rdb16w4Rab12w4Rmb8w4Rb5w1Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint R => (_value >> 5) & 0x1;
        public uint Rm => (_value >> 8) & 0xF;
        public uint Ra => (_value >> 12) & 0xF;
        public uint Rd => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rab12w4Rdb8w4Rb4w1Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rab12w4Rdb8w4Rb4w1Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint R => (_value >> 4) & 0x1;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Ra => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Rdb16w4Rmb8w4Rb5w1Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rdb16w4Rmb8w4Rb5w1Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint R => (_value >> 5) & 0x1;
        public uint Rm => (_value >> 8) & 0xF;
        public uint Rd => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rdb8w4Rb4w1Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rdb8w4Rb4w1Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint R => (_value >> 4) & 0x1;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Rdb16w4Rmb8w4Mb5w1Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rdb16w4Rmb8w4Mb5w1Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Rm => (_value >> 8) & 0xF;
        public uint Rd => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rdb8w4Mb4w1Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rdb8w4Mb4w1Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint M => (_value >> 4) & 0x1;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Rdb16w4Rmb8w4Mb6w1Nb5w1Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rdb16w4Rmb8w4Mb6w1Nb5w1Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint N => (_value >> 5) & 0x1;
        public uint M => (_value >> 6) & 0x1;
        public uint Rm => (_value >> 8) & 0xF;
        public uint Rd => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rdb8w4Nb5w1Mb4w1Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rdb8w4Nb5w1Mb4w1Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint M => (_value >> 4) & 0x1;
        public uint N => (_value >> 5) & 0x1;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Rdb16w4Rmb8w4Mb6w1Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rdb16w4Rmb8w4Mb6w1Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint M => (_value >> 6) & 0x1;
        public uint Rm => (_value >> 8) & 0xF;
        public uint Rd => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstCondb28w4SatImmb16w5Rdb12w4Imm5b7w5Shb6w1Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4SatImmb16w5Rdb12w4Imm5b7w5Shb6w1Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint Sh => (_value >> 6) & 0x1;
        public uint Imm5 => (_value >> 7) & 0x1F;
        public uint Rd => (_value >> 12) & 0xF;
        public uint SatImm => (_value >> 16) & 0x1F;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstShb21w1Rnb16w4Imm3b12w3Rdb8w4Imm2b6w2SatImmb0w5
    {
        private readonly uint _value;
        public InstShb21w1Rnb16w4Imm3b12w3Rdb8w4Imm2b6w2SatImmb0w5(uint value) => _value = value;
        public uint SatImm => (_value >> 0) & 0x1F;
        public uint Imm2 => (_value >> 6) & 0x3;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Imm3 => (_value >> 12) & 0x7;
        public uint Rn => (_value >> 16) & 0xF;
        public uint Sh => (_value >> 21) & 0x1;
    }

    struct InstCondb28w4SatImmb16w4Rdb12w4Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4SatImmb16w4Rdb12w4Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint Rd => (_value >> 12) & 0xF;
        public uint SatImm => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rdb8w4SatImmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rdb8w4SatImmb0w4(uint value) => _value = value;
        public uint SatImm => (_value >> 0) & 0xF;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Rnb16w4Rtb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rnb16w4Rtb0w4(uint value) => _value = value;
        public uint Rt => (_value >> 0) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstCondb28w4Rnb16w4Rdb12w4Rtb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rnb16w4Rdb12w4Rtb0w4(uint value) => _value = value;
        public uint Rt => (_value >> 0) & 0xF;
        public uint Rd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rtb12w4Rdb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rtb12w4Rdb0w4(uint value) => _value = value;
        public uint Rd => (_value >> 0) & 0xF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstRnb16w4Rtb12w4Rt2b8w4Rdb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rtb12w4Rt2b8w4Rdb0w4(uint value) => _value = value;
        public uint Rd => (_value >> 0) & 0xF;
        public uint Rt2 => (_value >> 8) & 0xF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstWb21w1Rnb16w4Mb14w1RegisterListb0w14
    {
        private readonly uint _value;
        public InstWb21w1Rnb16w4Mb14w1RegisterListb0w14(uint value) => _value = value;
        public uint RegisterList => (_value >> 0) & 0x3FFF;
        public uint M => (_value >> 14) & 0x1;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
    }

    struct InstRnb16w4Rtb12w4Rdb8w4Imm8b0w8
    {
        private readonly uint _value;
        public InstRnb16w4Rtb12w4Rdb8w4Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Rnb16w4Rdb12w4Rotateb10w2Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rnb16w4Rdb12w4Rotateb10w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Rotate => (_value >> 10) & 0x3;
        public uint Rd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRnb16w4Rdb8w4Rotateb4w2Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Rdb8w4Rotateb4w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Rotate => (_value >> 4) & 0x3;
        public uint Rd => (_value >> 8) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Rdb12w4Rotateb10w2Rmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rdb12w4Rotateb10w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Rotate => (_value >> 10) & 0x3;
        public uint Rd => (_value >> 12) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRdb8w4Rotateb4w2Rmb0w4
    {
        private readonly uint _value;
        public InstRdb8w4Rotateb4w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Rotate => (_value >> 4) & 0x3;
        public uint Rd => (_value >> 8) & 0xF;
    }

    struct InstRnb16w4Hb4w1Rmb0w4
    {
        private readonly uint _value;
        public InstRnb16w4Hb4w1Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint H => (_value >> 4) & 0x1;
        public uint Rn => (_value >> 16) & 0xF;
    }

    struct InstImm12b8w12Imm4b0w4
    {
        private readonly uint _value;
        public InstImm12b8w12Imm4b0w4(uint value) => _value = value;
        public uint Imm4 => (_value >> 0) & 0xF;
        public uint Imm12 => (_value >> 8) & 0xFFF;
    }

    struct InstImm4b16w4Imm12b0w12
    {
        private readonly uint _value;
        public InstImm4b16w4Imm12b0w12(uint value) => _value = value;
        public uint Imm12 => (_value >> 0) & 0xFFF;
        public uint Imm4 => (_value >> 16) & 0xF;
    }

    struct InstCondb28w4Rdhib16w4Rdlob12w4Rmb8w4Rnb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Rdhib16w4Rdlob12w4Rmb8w4Rnb0w4(uint value) => _value = value;
        public uint Rn => (_value >> 0) & 0xF;
        public uint Rm => (_value >> 8) & 0xF;
        public uint Rdlo => (_value >> 12) & 0xF;
        public uint Rdhi => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstUb24w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb24w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Size => (_value >> 20) & 0x3;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 24) & 0x1;
    }

    struct InstUb28w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb28w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Size => (_value >> 20) & 0x3;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 28) & 0x1;
    }

    struct InstUb24w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb24w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Size => (_value >> 20) & 0x3;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 24) & 0x1;
    }

    struct InstUb28w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb28w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Size => (_value >> 20) & 0x3;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 28) & 0x1;
    }

    struct InstDb22w1Szb20w1Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Szb20w1Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Sz => (_value >> 20) & 0x1;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstDb22w1Sizeb18w2Vdb12w4Fb10w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Sizeb18w2Vdb12w4Fb10w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint F => (_value >> 10) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Size => (_value >> 18) & 0x3;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstCondb28w4Db22w1Vdb12w4Sizeb8w2Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Db22w1Vdb12w4Sizeb8w2Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Size => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint D => (_value >> 22) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstDb22w1Vdb12w4Sizeb8w2Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Vdb12w4Sizeb8w2Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Size => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstDb22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Size => (_value >> 20) & 0x3;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstCondb28w4Db22w1Vnb16w4Vdb12w4Sizeb8w2Nb7w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Db22w1Vnb16w4Vdb12w4Sizeb8w2Nb7w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Size => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint D => (_value >> 22) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstDb22w1Vnb16w4Vdb12w4Sizeb8w2Nb7w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Vnb16w4Vdb12w4Sizeb8w2Nb7w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Size => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstDb22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Size => (_value >> 20) & 0x3;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstIb24w1Db22w1Imm3b16w3Vdb12w4Qb6w1Imm4b0w4
    {
        private readonly uint _value;
        public InstIb24w1Db22w1Imm3b16w3Vdb12w4Qb6w1Imm4b0w4(uint value) => _value = value;
        public uint Imm4 => (_value >> 0) & 0xF;
        public uint Q => (_value >> 6) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm3 => (_value >> 16) & 0x7;
        public uint D => (_value >> 22) & 0x1;
        public uint I => (_value >> 24) & 0x1;
    }

    struct InstIb28w1Db22w1Imm3b16w3Vdb12w4Qb6w1Imm4b0w4
    {
        private readonly uint _value;
        public InstIb28w1Db22w1Imm3b16w3Vdb12w4Qb6w1Imm4b0w4(uint value) => _value = value;
        public uint Imm4 => (_value >> 0) & 0xF;
        public uint Q => (_value >> 6) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm3 => (_value >> 16) & 0x7;
        public uint D => (_value >> 22) & 0x1;
        public uint I => (_value >> 28) & 0x1;
    }

    struct InstRotb24w1Db22w1Sb20w1Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstRotb24w1Db22w1Sb20w1Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint S => (_value >> 20) & 0x1;
        public uint D => (_value >> 22) & 0x1;
        public uint Rot => (_value >> 24) & 0x1;
    }

    struct InstDb22w1Sizeb18w2Vdb12w4Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Sizeb18w2Vdb12w4Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Size => (_value >> 18) & 0x3;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstRotb23w2Db22w1Sb20w1Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstRotb23w2Db22w1Sb20w1Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint S => (_value >> 20) & 0x1;
        public uint D => (_value >> 22) & 0x1;
        public uint Rot => (_value >> 23) & 0x3;
    }

    struct InstSb23w1Db22w1Rotb20w2Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstSb23w1Db22w1Rotb20w2Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Rot => (_value >> 20) & 0x3;
        public uint D => (_value >> 22) & 0x1;
        public uint S => (_value >> 23) & 0x1;
    }

    struct InstCondb28w4Db22w1Vdb12w4Sizeb8w2
    {
        private readonly uint _value;
        public InstCondb28w4Db22w1Vdb12w4Sizeb8w2(uint value) => _value = value;
        public uint Size => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint D => (_value >> 22) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstDb22w1Vdb12w4Sizeb8w2
    {
        private readonly uint _value;
        public InstDb22w1Vdb12w4Sizeb8w2(uint value) => _value = value;
        public uint Size => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstDb22w1Sizeb18w2Vdb12w4Opb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Sizeb18w2Vdb12w4Opb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint Op => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Size => (_value >> 18) & 0x3;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstDb22w1Vdb12w4Sizeb8w2Opb7w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Vdb12w4Sizeb8w2Opb7w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Op => (_value >> 7) & 0x1;
        public uint Size => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstCondb28w4Db22w1Opb16w1Vdb12w4Szb8w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Db22w1Opb16w1Vdb12w4Szb8w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Sz => (_value >> 8) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Op => (_value >> 16) & 0x1;
        public uint D => (_value >> 22) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstDb22w1Opb16w1Vdb12w4Szb8w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Opb16w1Vdb12w4Szb8w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Sz => (_value >> 8) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Op => (_value >> 16) & 0x1;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstCondb28w4Db22w1Vdb12w4Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Db22w1Vdb12w4Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint D => (_value >> 22) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstDb22w1Vdb12w4Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Vdb12w4Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstDb22w1Sizeb18w2Vdb12w4Opb8w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Sizeb18w2Vdb12w4Opb8w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Op => (_value >> 8) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Size => (_value >> 18) & 0x3;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstDb22w1Sizeb18w2Vdb12w4Opb7w2Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Sizeb18w2Vdb12w4Opb7w2Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint Op => (_value >> 7) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Size => (_value >> 18) & 0x3;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstCondb28w4Db22w1Vdb12w4Sizeb8w2Opb7w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Db22w1Vdb12w4Sizeb8w2Opb7w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Op => (_value >> 7) & 0x1;
        public uint Size => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint D => (_value >> 22) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstUb24w1Db22w1Imm6b16w6Vdb12w4Opb8w2Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb24w1Db22w1Imm6b16w6Vdb12w4Opb8w2Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint Op => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm6 => (_value >> 16) & 0x3F;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 24) & 0x1;
    }

    struct InstUb28w1Db22w1Imm6b16w6Vdb12w4Opb8w2Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb28w1Db22w1Imm6b16w6Vdb12w4Opb8w2Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint Op => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm6 => (_value >> 16) & 0x3F;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 28) & 0x1;
    }

    struct InstCondb28w4Db22w1Opb18w1Ub16w1Vdb12w4Sfb8w2Sxb7w1Ib5w1Imm4b0w4
    {
        private readonly uint _value;
        public InstCondb28w4Db22w1Opb18w1Ub16w1Vdb12w4Sfb8w2Sxb7w1Ib5w1Imm4b0w4(uint value) => _value = value;
        public uint Imm4 => (_value >> 0) & 0xF;
        public uint I => (_value >> 5) & 0x1;
        public uint Sx => (_value >> 7) & 0x1;
        public uint Sf => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint U => (_value >> 16) & 0x1;
        public uint Op => (_value >> 18) & 0x1;
        public uint D => (_value >> 22) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstDb22w1Opb18w1Ub16w1Vdb12w4Sfb8w2Sxb7w1Ib5w1Imm4b0w4
    {
        private readonly uint _value;
        public InstDb22w1Opb18w1Ub16w1Vdb12w4Sfb8w2Sxb7w1Ib5w1Imm4b0w4(uint value) => _value = value;
        public uint Imm4 => (_value >> 0) & 0xF;
        public uint I => (_value >> 5) & 0x1;
        public uint Sx => (_value >> 7) & 0x1;
        public uint Sf => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint U => (_value >> 16) & 0x1;
        public uint Op => (_value >> 18) & 0x1;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstCondb28w4Bb22w1Qb21w1Vdb16w4Rtb12w4Db7w1Eb5w1
    {
        private readonly uint _value;
        public InstCondb28w4Bb22w1Qb21w1Vdb16w4Rtb12w4Db7w1Eb5w1(uint value) => _value = value;
        public uint E => (_value >> 5) & 0x1;
        public uint D => (_value >> 7) & 0x1;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Vd => (_value >> 16) & 0xF;
        public uint Q => (_value >> 21) & 0x1;
        public uint B => (_value >> 22) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstBb22w1Qb21w1Vdb16w4Rtb12w4Db7w1Eb5w1
    {
        private readonly uint _value;
        public InstBb22w1Qb21w1Vdb16w4Rtb12w4Db7w1Eb5w1(uint value) => _value = value;
        public uint E => (_value >> 5) & 0x1;
        public uint D => (_value >> 7) & 0x1;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Vd => (_value >> 16) & 0xF;
        public uint Q => (_value >> 21) & 0x1;
        public uint B => (_value >> 22) & 0x1;
    }

    struct InstDb22w1Imm4b16w4Vdb12w4Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Imm4b16w4Vdb12w4Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm4 => (_value >> 16) & 0xF;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstDb22w1Vnb16w4Vdb12w4Imm4b8w4Nb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Vnb16w4Vdb12w4Imm4b8w4Nb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Imm4 => (_value >> 8) & 0xF;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstDb22w1Rnb16w4Vdb12w4IndexAlignb4w4Rmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Rnb16w4Vdb12w4IndexAlignb4w4Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint IndexAlign => (_value >> 4) & 0xF;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstDb22w1Rnb16w4Vdb12w4Sizeb6w2Tb5w1Ab4w1Rmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Rnb16w4Vdb12w4Sizeb6w2Tb5w1Ab4w1Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint A => (_value >> 4) & 0x1;
        public uint T => (_value >> 5) & 0x1;
        public uint Size => (_value >> 6) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstDb22w1Rnb16w4Vdb12w4Sizeb6w2Alignb4w2Rmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Rnb16w4Vdb12w4Sizeb6w2Alignb4w2Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint Align => (_value >> 4) & 0x3;
        public uint Size => (_value >> 6) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstDb22w1Rnb16w4Vdb12w4Sizeb6w2Tb5w1Rmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Rnb16w4Vdb12w4Sizeb6w2Tb5w1Rmb0w4(uint value) => _value = value;
        public uint Rm => (_value >> 0) & 0xF;
        public uint T => (_value >> 5) & 0x1;
        public uint Size => (_value >> 6) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstCondb28w4Pb24w1Ub23w1Db22w1Wb21w1Rnb16w4Vdb12w4Imm8b0w8
    {
        private readonly uint _value;
        public InstCondb28w4Pb24w1Ub23w1Db22w1Wb21w1Rnb16w4Vdb12w4Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint P => (_value >> 24) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstPb24w1Ub23w1Db22w1Wb21w1Rnb16w4Vdb12w4Imm8b0w8
    {
        private readonly uint _value;
        public InstPb24w1Ub23w1Db22w1Wb21w1Rnb16w4Vdb12w4Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint W => (_value >> 21) & 0x1;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint P => (_value >> 24) & 0x1;
    }

    struct InstCondb28w4Ub23w1Db22w1Rnb16w4Vdb12w4Sizeb8w2Imm8b0w8
    {
        private readonly uint _value;
        public InstCondb28w4Ub23w1Db22w1Rnb16w4Vdb12w4Sizeb8w2Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Size => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstUb23w1Db22w1Rnb16w4Vdb12w4Sizeb8w2Imm8b0w8
    {
        private readonly uint _value;
        public InstUb23w1Db22w1Rnb16w4Vdb12w4Sizeb8w2Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Size => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Rn => (_value >> 16) & 0xF;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 23) & 0x1;
    }

    struct InstCondb28w4Ub23w1Db22w1Vdb12w4Sizeb8w2Imm8b0w8
    {
        private readonly uint _value;
        public InstCondb28w4Ub23w1Db22w1Vdb12w4Sizeb8w2Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Size => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 23) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstUb23w1Db22w1Vdb12w4Sizeb8w2Imm8b0w8
    {
        private readonly uint _value;
        public InstUb23w1Db22w1Vdb12w4Sizeb8w2Imm8b0w8(uint value) => _value = value;
        public uint Imm8 => (_value >> 0) & 0xFF;
        public uint Size => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 23) & 0x1;
    }

    struct InstQb24w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Fb8w1Nb7w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstQb24w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Fb8w1Nb7w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint F => (_value >> 8) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Size => (_value >> 20) & 0x3;
        public uint D => (_value >> 22) & 0x1;
        public uint Q => (_value >> 24) & 0x1;
    }

    struct InstQb28w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Fb8w1Nb7w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstQb28w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Fb8w1Nb7w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint F => (_value >> 8) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Size => (_value >> 20) & 0x3;
        public uint D => (_value >> 22) & 0x1;
        public uint Q => (_value >> 28) & 0x1;
    }

    struct InstDb22w1Vnb16w4Vdb12w4Nb7w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Vnb16w4Vdb12w4Nb7w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstUb24w1Db22w1Imm3hb19w3Vdb12w4Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb24w1Db22w1Imm3hb19w3Vdb12w4Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm3h => (_value >> 19) & 0x7;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 24) & 0x1;
    }

    struct InstUb28w1Db22w1Imm3hb19w3Vdb12w4Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb28w1Db22w1Imm3hb19w3Vdb12w4Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm3h => (_value >> 19) & 0x7;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 28) & 0x1;
    }

    struct InstCondb28w4Opb20w1Rt2b16w4Rtb12w4Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Opb20w1Rt2b16w4Rtb12w4Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rt2 => (_value >> 16) & 0xF;
        public uint Op => (_value >> 20) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstOpb20w1Rt2b16w4Rtb12w4Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstOpb20w1Rt2b16w4Rtb12w4Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Rt2 => (_value >> 16) & 0xF;
        public uint Op => (_value >> 20) & 0x1;
    }

    struct InstCondb28w4Opb20w1Vnb16w4Rtb12w4Nb7w1
    {
        private readonly uint _value;
        public InstCondb28w4Opb20w1Vnb16w4Rtb12w4Nb7w1(uint value) => _value = value;
        public uint N => (_value >> 7) & 0x1;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Op => (_value >> 20) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstOpb20w1Vnb16w4Rtb12w4Nb7w1
    {
        private readonly uint _value;
        public InstOpb20w1Vnb16w4Rtb12w4Nb7w1(uint value) => _value = value;
        public uint N => (_value >> 7) & 0x1;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Op => (_value >> 20) & 0x1;
    }

    struct InstCondb28w4Db22w1Imm4hb16w4Vdb12w4Sizeb8w2Imm4lb0w4
    {
        private readonly uint _value;
        public InstCondb28w4Db22w1Imm4hb16w4Vdb12w4Sizeb8w2Imm4lb0w4(uint value) => _value = value;
        public uint Imm4l => (_value >> 0) & 0xF;
        public uint Size => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm4h => (_value >> 16) & 0xF;
        public uint D => (_value >> 22) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstDb22w1Imm4hb16w4Vdb12w4Sizeb8w2Imm4lb0w4
    {
        private readonly uint _value;
        public InstDb22w1Imm4hb16w4Vdb12w4Sizeb8w2Imm4lb0w4(uint value) => _value = value;
        public uint Imm4l => (_value >> 0) & 0xF;
        public uint Size => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm4h => (_value >> 16) & 0xF;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstCondb28w4Opc1b21w2Vdb16w4Rtb12w4Db7w1Opc2b5w2
    {
        private readonly uint _value;
        public InstCondb28w4Opc1b21w2Vdb16w4Rtb12w4Db7w1Opc2b5w2(uint value) => _value = value;
        public uint Opc2 => (_value >> 5) & 0x3;
        public uint D => (_value >> 7) & 0x1;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Vd => (_value >> 16) & 0xF;
        public uint Opc1 => (_value >> 21) & 0x3;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstOpc1b21w2Vdb16w4Rtb12w4Db7w1Opc2b5w2
    {
        private readonly uint _value;
        public InstOpc1b21w2Vdb16w4Rtb12w4Db7w1Opc2b5w2(uint value) => _value = value;
        public uint Opc2 => (_value >> 5) & 0x3;
        public uint D => (_value >> 7) & 0x1;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Vd => (_value >> 16) & 0xF;
        public uint Opc1 => (_value >> 21) & 0x3;
    }

    struct InstCondb28w4Ub23w1Opc1b21w2Vnb16w4Rtb12w4Nb7w1Opc2b5w2
    {
        private readonly uint _value;
        public InstCondb28w4Ub23w1Opc1b21w2Vnb16w4Rtb12w4Nb7w1Opc2b5w2(uint value) => _value = value;
        public uint Opc2 => (_value >> 5) & 0x3;
        public uint N => (_value >> 7) & 0x1;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Opc1 => (_value >> 21) & 0x3;
        public uint U => (_value >> 23) & 0x1;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstUb23w1Opc1b21w2Vnb16w4Rtb12w4Nb7w1Opc2b5w2
    {
        private readonly uint _value;
        public InstUb23w1Opc1b21w2Vnb16w4Rtb12w4Nb7w1Opc2b5w2(uint value) => _value = value;
        public uint Opc2 => (_value >> 5) & 0x3;
        public uint N => (_value >> 7) & 0x1;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Opc1 => (_value >> 21) & 0x3;
        public uint U => (_value >> 23) & 0x1;
    }

    struct InstCondb28w4Regb16w4Rtb12w4
    {
        private readonly uint _value;
        public InstCondb28w4Regb16w4Rtb12w4(uint value) => _value = value;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Reg => (_value >> 16) & 0xF;
        public uint Cond => (_value >> 28) & 0xF;
    }

    struct InstRegb16w4Rtb12w4
    {
        private readonly uint _value;
        public InstRegb16w4Rtb12w4(uint value) => _value = value;
        public uint Rt => (_value >> 12) & 0xF;
        public uint Reg => (_value >> 16) & 0xF;
    }

    struct InstUb24w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Opb9w1Nb7w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb24w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Opb9w1Nb7w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Op => (_value >> 9) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Size => (_value >> 20) & 0x3;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 24) & 0x1;
    }

    struct InstUb28w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Opb9w1Nb7w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb28w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Opb9w1Nb7w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Op => (_value >> 9) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Size => (_value >> 20) & 0x3;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 28) & 0x1;
    }

    struct InstOpb24w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstOpb24w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Size => (_value >> 20) & 0x3;
        public uint D => (_value >> 22) & 0x1;
        public uint Op => (_value >> 24) & 0x1;
    }

    struct InstOpb28w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstOpb28w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Size => (_value >> 20) & 0x3;
        public uint D => (_value >> 22) & 0x1;
        public uint Op => (_value >> 28) & 0x1;
    }

    struct InstDb22w1Szb20w1Vnb16w4Vdb12w4Nb7w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Szb20w1Vnb16w4Vdb12w4Nb7w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Sz => (_value >> 20) & 0x1;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstQb24w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstQb24w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Size => (_value >> 20) & 0x3;
        public uint D => (_value >> 22) & 0x1;
        public uint Q => (_value >> 24) & 0x1;
    }

    struct InstQb28w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstQb28w1Db22w1Sizeb20w2Vnb16w4Vdb12w4Nb7w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Size => (_value >> 20) & 0x3;
        public uint D => (_value >> 22) & 0x1;
        public uint Q => (_value >> 28) & 0x1;
    }

    struct InstDb22w1Sizeb18w2Vdb12w4Opb6w2Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Sizeb18w2Vdb12w4Opb6w2Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Op => (_value >> 6) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Size => (_value >> 18) & 0x3;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstUb24w1Db22w1Imm6b16w6Vdb12w4Opb8w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb24w1Db22w1Imm6b16w6Vdb12w4Opb8w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Op => (_value >> 8) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm6 => (_value >> 16) & 0x3F;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 24) & 0x1;
    }

    struct InstUb28w1Db22w1Imm6b16w6Vdb12w4Opb8w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb28w1Db22w1Imm6b16w6Vdb12w4Opb8w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Op => (_value >> 8) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm6 => (_value >> 16) & 0x3F;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 28) & 0x1;
    }

    struct InstUb24w1Db22w1Imm6b16w6Vdb12w4Opb8w1Lb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb24w1Db22w1Imm6b16w6Vdb12w4Opb8w1Lb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint L => (_value >> 7) & 0x1;
        public uint Op => (_value >> 8) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm6 => (_value >> 16) & 0x3F;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 24) & 0x1;
    }

    struct InstUb28w1Db22w1Imm6b16w6Vdb12w4Opb8w1Lb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb28w1Db22w1Imm6b16w6Vdb12w4Opb8w1Lb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint L => (_value >> 7) & 0x1;
        public uint Op => (_value >> 8) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm6 => (_value >> 16) & 0x3F;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 28) & 0x1;
    }

    struct InstDb22w1Sizeb18w2Vdb12w4Fb8w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Sizeb18w2Vdb12w4Fb8w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint F => (_value >> 8) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Size => (_value >> 18) & 0x3;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstUb24w1Db22w1Imm6b16w6Vdb12w4Lb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb24w1Db22w1Imm6b16w6Vdb12w4Lb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint L => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm6 => (_value >> 16) & 0x3F;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 24) & 0x1;
    }

    struct InstUb28w1Db22w1Imm6b16w6Vdb12w4Lb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb28w1Db22w1Imm6b16w6Vdb12w4Lb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint L => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm6 => (_value >> 16) & 0x3F;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 28) & 0x1;
    }

    struct InstDb22w1Imm6b16w6Vdb12w4Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Imm6b16w6Vdb12w4Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm6 => (_value >> 16) & 0x3F;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstDb22w1Ccb20w2Vnb16w4Vdb12w4Sizeb8w2Nb7w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Ccb20w2Vnb16w4Vdb12w4Sizeb8w2Nb7w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Size => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint Cc => (_value >> 20) & 0x3;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstUb24w1Db22w1Imm6b16w6Vdb12w4Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb24w1Db22w1Imm6b16w6Vdb12w4Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm6 => (_value >> 16) & 0x3F;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 24) & 0x1;
    }

    struct InstUb28w1Db22w1Imm6b16w6Vdb12w4Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstUb28w1Db22w1Imm6b16w6Vdb12w4Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm6 => (_value >> 16) & 0x3F;
        public uint D => (_value >> 22) & 0x1;
        public uint U => (_value >> 28) & 0x1;
    }

    struct InstDb22w1Imm6b16w6Vdb12w4Lb7w1Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Imm6b16w6Vdb12w4Lb7w1Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint L => (_value >> 7) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Imm6 => (_value >> 16) & 0x3F;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstDb22w1Vdb12w4Qb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Vdb12w4Qb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Q => (_value >> 6) & 0x1;
        public uint Vd => (_value >> 12) & 0xF;
        public uint D => (_value >> 22) & 0x1;
    }

    struct InstDb22w1Vnb16w4Vdb12w4Lenb8w2Nb7w1Opb6w1Mb5w1Vmb0w4
    {
        private readonly uint _value;
        public InstDb22w1Vnb16w4Vdb12w4Lenb8w2Nb7w1Opb6w1Mb5w1Vmb0w4(uint value) => _value = value;
        public uint Vm => (_value >> 0) & 0xF;
        public uint M => (_value >> 5) & 0x1;
        public uint Op => (_value >> 6) & 0x1;
        public uint N => (_value >> 7) & 0x1;
        public uint Len => (_value >> 8) & 0x3;
        public uint Vd => (_value >> 12) & 0xF;
        public uint Vn => (_value >> 16) & 0xF;
        public uint D => (_value >> 22) & 0x1;
    }
}