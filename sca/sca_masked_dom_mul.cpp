#include "Context.h"
#include "CorrSet.h"
#include "Expr.h"
#include "StaticExpr.h"
#include "TransientExpr.h"
#include "SboxChecker.h"
#include "PtrVector.h"

#include <cassert>
#include <vector>
#include <array>

#define TRANSIENT
#ifndef TRANSIENT
    using V = StaticExpr;
#else
    using V = TransientExpr;
#endif

void test_dut()
{
    constexpr uint32_t NUM_RANDOM = NUM_SHARES * (NUM_SHARES - 1) / 2;
    SboxChecker<V> checker(FILE_PATH, TOP_MODULE);

    /// @todo Implement a cocoverif testbench for your DOM Multiplier.

    /// @details The API of SboxChecker is quite straightforward, and you
    /// can look at sca_masked_xor.cpp for an example use. First, declare
    /// your secrets using SboxChecker::new_secret<V> with NUM_SHARES
    /// shares and store it into a PtrVector<V> type variable. Similarly
    /// also create masks using SboxChecker::new_masks<V>. Your design
    /// probably uses registers that need to be clocked and reset, and you
    /// should just declare thee signals as single-bit constants 1 and 0
    /// using SboxChecker::new_constant<V>.

    /// @details Afterwards, you should place these values at the input
    /// ports of your design using SboxChecker::set . When ready and all
    /// input ports have been set, simply rung SboxChecker::interpret to
    /// symbolically interpret your pipelined design. Take note that
    /// this does not replace checks with verilator as cocoverif is very
    /// forgiving if you make pipelining errors. After interpretation, use
    /// SboxChecker::get and SboxChecker::declare_output to retrieve and
    /// mark your DOM output as a design output (only needed for SNI/PINI).
    
    {
        PtrVector<V> tuple = checker.check_sim_property<V>(NUM_SHARES - 1, Context::ni_t::NI);
        if (!tuple.empty()) checker.print_violation(tuple);
    }
    {
        PtrVector<V> tuple = checker.check_sim_property<V>(NUM_SHARES - 1, Context::ni_t::SNI);
        if (!tuple.empty()) checker.print_violation(tuple);
    }
    {
        PtrVector<V> tuple = checker.check_sim_property<V>(NUM_SHARES - 1, Context::ni_t::PINI);
        if (!tuple.empty()) checker.print_violation(tuple);
    }
}

int main()
{
    test_dut();
    return 0;
}