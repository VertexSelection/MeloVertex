//
//  Ryujinx-Header.h
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

#define DRM 0
#define CS_DEBUGGED 0x10000000

#ifndef RyujinxHeader
#define RyujinxHeader


#include <SDL2/SDL.h>
#include <SDL2/SDL_syswm.h>
#import "utils.h"


#ifdef __cplusplus
extern "C" {
#endif

struct GameInfo {
    long FileSize;
    char TitleName[512];
    char TitleId[32];
    char Developer[256];
    char Version[16];
    unsigned char* ImageData;
    unsigned int ImageSize;
};

extern struct GameInfo get_game_info(int, char*);

void install_firmware(const char* inputPtr);

char* installed_firmware_version();

void stop_emulation();

int main_ryujinx_sdl(int argc, char **argv);

int get_current_fps();

void initialize();

#ifdef __cplusplus
}
#endif

#endif /* RyujinxSDL_h */

