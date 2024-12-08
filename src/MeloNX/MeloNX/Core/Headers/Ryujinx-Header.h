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

// Declare the main_ryujinx_sdl function, matching the signature
int main_ryujinx_sdl(int argc, char **argv);

const char* get_game_controllers();

#ifdef __cplusplus
}
#endif

#endif /* RyujinxSDL_h */

