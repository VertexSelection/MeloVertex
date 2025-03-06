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

struct DlcNcaListItem {
    char Path[256];
    unsigned long TitleId;
};

struct DlcNcaList {
    bool success;
    unsigned int size;
    struct DlcNcaListItem* items;
};

extern struct GameInfo get_game_info(int, char*);

extern struct DlcNcaList get_dlc_nca_list(const char* titleIdPtr, const char* pathPtr);

void install_firmware(const char* inputPtr);

char* installed_firmware_version();

void set_native_window(void *layerPtr);

void stop_emulation();

void initialize();

int main_ryujinx_sdl(int argc, char **argv);

int get_current_fps();

void touch_began(float x, float y, int index);

void touch_moved(float x, float y, int index);

void touch_ended(int index);

#ifdef __cplusplus
}
#endif

#endif /* RyujinxSDL_h */

