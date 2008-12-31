/* global_setup.h
 *  Copyright (C) 2001-2007, The Perl Foundation.
 *  SVN Info
 *     $Id$
 *  Overview:
 *      Contains declarations of global data and the functions
 *      that initialize that data.
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#ifndef PARROT_GLOBAL_SETUP_H_GUARD
#define PARROT_GLOBAL_SETUP_H_GUARD

#include "parrot/config.h"
#include "parrot/interpreter.h"

/* HEADERIZER BEGIN: src/global_setup.c */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_EXPORT
void Parrot_set_config_hash_internal(
    ARGIN(const unsigned char* parrot_config),
    unsigned int parrot_config_size)
        __attribute__nonnull__(1);

void init_world(PARROT_INTERP)
        __attribute__nonnull__(1);

void init_world_once(PARROT_INTERP)
        __attribute__nonnull__(1);

void parrot_global_setup_2(PARROT_INTERP)
        __attribute__nonnull__(1);

#define ASSERT_ARGS_Parrot_set_config_hash_internal assert(parrot_config);
#define ASSERT_ARGS_init_world assert(interp);
#define ASSERT_ARGS_init_world_once assert(interp);
#define ASSERT_ARGS_parrot_global_setup_2 assert(interp);
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: src/global_setup.c */

#endif /* PARROT_GLOBAL_SETUP_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
