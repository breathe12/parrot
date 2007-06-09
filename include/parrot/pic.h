/* pic.h
 *  Copyright (C) 2005, The Perl Foundation.
 *  SVN Info
 *     $Id$
 *  Overview:
 *     This is the api header for the pic subsystem
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#pragma once
#ifndef PARROT_PIC_H_GUARD
#define PARROT_PIC_H_GUARD

/*
 * one cache slot
 *
 * if types exceed 16 bits or for general MMD function calls an
 * extended cache slot is needed with more type entries
 */
typedef struct Parrot_pic_lru_t {
    union {
        INTVAL type;                    /* for MMD left << 16 | right type */
        PMC *signature;                 /* arg passing signature */
    } u;
    union {
        funcptr_t real_function;        /* the actual C code */
        PMC *sub;                       /* or a Sub PMC */
        PMC **pattr;                    /* attribute location */
    } f;
} Parrot_PIC_lru;

/*
 * PIC 3 more cache slots
 */
typedef struct Parrot_pic_t {
    Parrot_PIC_lru lru[3];              /* PIC - three more cache entries */
    INTVAL miss_count;                  /* how many misses */
} Parrot_PIC;

/*
 * the main used MIC one cache slot - 4 words size
 */
typedef struct Parrot_mic_t {
    Parrot_PIC_lru lru;                 /* MIC - one cache */
    union {
        STRING *method;                 /* for callmethod */
        INTVAL func_nr;                 /* MMD function number */
        STRING *attribute;              /* obj.attribute */
        PMC *sig;                       /* arg passing */
    } m;
    Parrot_PIC *pic;                    /* more cache entries */
} Parrot_MIC;

/*
 * memory is managed by this structure hanging off a
 * PackFile_ByteCode segment
 */
typedef struct Parrot_pic_store_t {
    struct Parrot_pic_store_t *prev;    /* prev pic_store */
    size_t usable;                      /* size of usable memory: */
    Parrot_PIC *pic;                    /* from rear */
    Parrot_MIC *mic;                    /* idx access to allocated MICs */
    size_t n_mics;                      /* range check, debugging mainly */
} Parrot_PIC_store;

typedef int (*arg_pass_f)(Interp *, PMC *sig,
            char *src_base, void **src_pc, char *dest_base, void **dest_pc);

/* more or less private interfaces */

/* HEADERIZER BEGIN: src/pic.c */

Parrot_MIC* parrot_PIC_alloc_mic( Interp *interp, size_t n );
Parrot_PIC* parrot_PIC_alloc_pic( Interp *interp );
void parrot_PIC_alloc_store( Interp *interp,
    struct PackFile_ByteCode *cs /*NN*/,
    size_t n )
        __attribute__nonnull__(2);

int parrot_pic_check_sig( Interp *interp,
    const PMC *sig1 /*NN*/,
    const PMC *sig2 /*NN*/,
    int *type /*NN*/ )
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4);

void parrot_PIC_destroy( Interp *interp, struct PackFile_ByteCode *cs /*NN*/ )
        __attribute__nonnull__(2);

void parrot_pic_find_infix_v_pp( Interp *interp,
    PMC *left /*NN*/,
    PMC *right /*NN*/,
    Parrot_MIC *mic /*NN*/,
    opcode_t *cur_opcode /*NN*/ )
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        __attribute__nonnull__(5);

int parrot_PIC_op_is_cached( Interp *interp, int op_code );
void * parrot_pic_opcode( Interp *interp, INTVAL op );
void parrot_PIC_prederef( Interp *interp,
    opcode_t op,
    void **pc_pred,
    int core );

/* HEADERIZER END: src/pic.c */


int parrot_pic_is_safe_to_jit(Interp *, PMC *sub,
        PMC *sig_args, PMC *sig_results, int *flags);

funcptr_t  parrot_pic_JIT_sub(Interp *, PMC *sub, int flags);

#endif /* PARROT_PIC_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
