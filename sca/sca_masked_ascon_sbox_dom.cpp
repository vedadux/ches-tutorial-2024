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
    constexpr uint32_t NUM_QUADRATIC = NUM_SHARES * (NUM_SHARES - 1) / 2;
    constexpr uint32_t NUM_RANDOM = 5 * NUM_QUADRATIC;
    
    SboxChecker<V> checker(FILE_PATH, TOP_MODULE);

    PtrVector<V> X;
    for (uint32_t i = 0; i < 5; i++)
    {
        PtrVector<V> Xi = checker.new_secret<V>(NUM_SHARES); 
        X = concat(Xi, X);
    }
    
    PtrVector<V> R = checker.new_masks<V>(NUM_RANDOM);
    PtrVector<V> clock = checker.new_constant<V>(1, 1);
    PtrVector<V> reset = checker.new_constant<V>(0, 1);
    
    checker.set("in_x", X);
    checker.set("in_random", R);
    checker.set("in_clock", clock);
    checker.set("in_reset", reset);
    
    checker.interpret();

    PtrVector<V> Y = checker.get("out_y");
    for (uint32_t i = 0; i < 5; i++)
    {
        checker.declare_output(Y.slice((i+1)*NUM_SHARES - 1, i*NUM_SHARES));
    }
    
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