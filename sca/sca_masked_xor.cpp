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

    PtrVector<V> A = checker.new_secret<V>(NUM_SHARES);
    PtrVector<V> B = checker.new_secret<V>(NUM_SHARES);
    
    checker.set("in_a", A);
    checker.set("in_b", B);
    
    checker.interpret();

    PtrVector<V> C = checker.get("out_c");
    checker.declare_output(C);

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