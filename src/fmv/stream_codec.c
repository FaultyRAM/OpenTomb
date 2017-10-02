
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include <SDL2/SDL.h>

#include "tiny_codec.h"
#include "stream_codec.h"

void stream_codec_init(stream_codec_p s)
{
    s->state = VIDEO_STATE_STOPPED;
    s->stop = 0;
    s->update_audio = 1;
    s->thread = NULL;
    s->timer_sem = SDL_CreateSemaphore(1);
    s->video_buffer_mutex = SDL_CreateMutex();
    s->audio_buffer_mutex = SDL_CreateMutex();
    codec_init(&s->codec, NULL);
}


void stream_codec_clear(stream_codec_p s)
{
    s->stop = 1;
    if(s->thread != NULL)
    {
        SDL_WaitThread(s->thread, NULL);
        s->thread = 0;
    }

    SDL_DestroySemaphore(s->timer_sem);
    SDL_DestroyMutex(s->video_buffer_mutex);
    SDL_DestroyMutex(s->audio_buffer_mutex);
}


int stream_codec_check_end(stream_codec_p s)
{
    if(s->state == VIDEO_STATE_STOPPED)
    {
        if(s->thread != NULL)
        {
            SDL_WaitThread(s->thread, NULL);
            s->thread = NULL;
            return 1;
        }
        return 0;
    }
    return -1;
}


void stream_codec_stop(stream_codec_p s, int wait)
{
    s->stop = 1;
    if(wait && s->thread != NULL)
    {
        SDL_WaitThread(s->thread, NULL);
        s->thread = NULL;
    }
}


static int stream_codec_thread_func(void *data)
{
    stream_codec_p s = (stream_codec_p)data;
    if(s)
    {
        uint64_t frame = 0;
        uint64_t ms = 0;
        Uint64 freq = SDL_GetPerformanceFrequency();
        Uint64 start_millis = SDL_GetPerformanceCounter() * 1000 / freq;
        Uint64 vid_millis = 0;
        int can_continue = 1;

        while(!s->stop && can_continue)
        {
            frame++;
            can_continue = 0;
            ms = (frame * s->codec.fps_denum) % s->codec.fps_num;
            ms = ms * 1000 / s->codec.fps_num;
            vid_millis = start_millis + ms;

            if(s->update_audio && s->codec.audio.decode && (s->codec.packet(&s->codec, &s->codec.audio.pkt) >= 0))
            {
                SDL_LockMutex(s->audio_buffer_mutex);
                s->codec.audio.decode(&s->codec, &s->codec.audio.pkt);
                s->update_audio = 0;
                SDL_UnlockMutex(s->audio_buffer_mutex);
            }

            if(s->codec.video.decode && (s->codec.packet(&s->codec, &s->codec.video.pkt) >= 0))
            {
                SDL_LockMutex(s->video_buffer_mutex);
                s->codec.video.decode(&s->codec, &s->codec.video.pkt);
                SDL_UnlockMutex(s->video_buffer_mutex);
                can_continue++;
            }

            s->state = VIDEO_STATE_RUNNING;
            SDL_SemWaitTimeout(s->timer_sem, (Uint32)(vid_millis));
        }
        s->state = VIDEO_STATE_QEUED;

        SDL_LockMutex(s->video_buffer_mutex);
        SDL_LockMutex(s->audio_buffer_mutex);
        codec_clear(&s->codec);
        SDL_UnlockMutex(s->audio_buffer_mutex);
        SDL_UnlockMutex(s->video_buffer_mutex);
        
        SDL_RWclose(s->codec.input);
        s->codec.input = NULL;
    }
    s->state = VIDEO_STATE_STOPPED;

    return 0;
}


void stream_codec_video_lock(stream_codec_p s)
{
    SDL_LockMutex(s->video_buffer_mutex);
}


void stream_codec_video_unlock(stream_codec_p s)
{
    SDL_UnlockMutex(s->video_buffer_mutex);
}


void stream_codec_audio_lock(stream_codec_p s)
{
    SDL_LockMutex(s->audio_buffer_mutex);
}


void stream_codec_audio_unlock(stream_codec_p s)
{
    SDL_UnlockMutex(s->audio_buffer_mutex);
}


int stream_codec_play(stream_codec_p s)
{
    if((s->state == VIDEO_STATE_STOPPED) && s->codec.input)
    {
        s->state = VIDEO_STATE_QEUED;
        s->stop = 0;
        s->thread = SDL_CreateThread(stream_codec_thread_func, "codec", s);
        return s->thread != NULL;
    }
    return 0;
}