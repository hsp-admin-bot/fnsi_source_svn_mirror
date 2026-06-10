using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace NKSConverter
{
    class ConverterTaskGroup<TWork>
    {
        private ConcurrentQueue<TWork> workQueue = new ConcurrentQueue<TWork>();
        private int taskCount = 1;
        private bool stopAll = false;


        public ConverterTaskGroup(int taskCount)
        {
            if (taskCount < 1)
            {
                taskCount = 1;
            }
            if (taskCount > 64)
            {
                taskCount = 64;
            }
            this.taskCount = taskCount;
        }

        public void addWork(TWork work)
        {
            workQueue.Enqueue(work);
        }

        public void run(Action<TWork> action)
        {
            stopAll = false;
            Task<bool>[] tasks = new Task<bool>[taskCount];
            for (int i = 0; i < taskCount; i++)
            {
                tasks[i] = new Task<bool>(() =>
                {
                    do
                    {
                        TWork work;
                        bool ret = workQueue.TryDequeue(out work);
                        if (!ret)
                        {
                            return true;
                        }
                        action(work);
                    } while (!stopAll);
                    return false;
                }, TaskCreationOptions.PreferFairness | TaskCreationOptions.LongRunning);
            }

            foreach (Task<bool> task in tasks)
            {
                task.Start();
            }

            do
            {
                Application.DoEvents();
                Thread.Sleep(10);

                bool allTaskEnd = true;
                foreach (Task<bool> task in tasks)
                {
                    //Application.DoEvents();
                    if (task.Status == TaskStatus.Faulted)
                    {
                        stopAll = true;
                    }
                    if (task.Status != TaskStatus.Canceled &&
                        task.Status != TaskStatus.RanToCompletion &&
                        task.Status != TaskStatus.Faulted)
                    {
                        allTaskEnd = false;
                    }
                }

                if (allTaskEnd)
                {
                    foreach (Task<bool> task in tasks)
                    {
                        bool exTest = task.Result;
                    }
                    return;
                }
            } while (true);

        }
    }
}
