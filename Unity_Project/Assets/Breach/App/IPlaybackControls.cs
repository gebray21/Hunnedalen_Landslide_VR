using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Breach.WildWaters.Apps
{
    public interface IPlaybackControls
    {
        void Play();
        void Pause();
        void Stop();
    }
}