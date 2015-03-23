#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>


// Choose a user environment to run and run it.
void
sched_yield(void)
{
    // Implement simple round-robin scheduling.
    // Search through 'envs' for a runnable environment,
    // in circular fashion starting after the previously running env,
    // and switch to the first such environment found.
    // It's OK to choose the previously running env if no other env
    // is runnable.
    // But never choose envs[0], the idle environment,
    // unless NOTHING else is runnable.

    // LAB 4: Your code here.
    static int i = 0;//the start index of the envs
    int j = 0;
    while (j != NENV) {
        i = (i+1)%NENV;
        //cprintf("i%NENV %d\n",i);
        //cprintf("env_status == ENV_RUNNABLE?%d\n",(envs[i].env_status - ENV_RUNNABLE));
        //start from the last environment
        if ( i && (envs[i].env_status == ENV_RUNNABLE)) {
            //if the i isn't the mulptiple of the NENV and it's runnnable
            //cprintf("run the envs[%d]\n",i);
            env_run(&envs[i]);
        }
        j++;
        //loop NENV times
    }
    // Run the special idle environment when nothing else is runnable.
    if (envs[0].env_status == ENV_RUNNABLE)
        env_run(&envs[0]);
    else {
        cprintf("Destroyed all environments - nothing more to do!\n");
        while (1)
            monitor(NULL);
    }
}
