//
//  Ryujinx-Header.h
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

#ifndef RyujinxHeader
#define RyujinxHeader


#import "SDL2/SDL.h"

#ifdef __cplusplus
extern "C" {
#endif

struct GameInfo {
    long FileSize;
    char TitleName[512];
    long TitleId;
    char Developer[256];
    int Version;
};
extern struct GameInfo get_game_info(int, char*);
// Declare the main_ryujinx_sdl function, matching the signature
int main_ryujinx_sdl(int argc, char **argv);

void initialize();

const char* get_game_controllers();

#ifdef __cplusplus
}
#endif

#endif /* RyujinxSDL_h */

