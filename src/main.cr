require "SDL2-Crystal/sdl2"

#    // Start up SDL, and make sure it went ok
#    //
#    uint32_t flags = SDL_INIT_TIMER | SDL_INIT_VIDEO | SDL_INIT_EVENTS;
#    if (SDL_Init(SDL_INIT_EVERYTHING) != 0) {
#
#        fprintf(stderr,
#                "\nUnable to initialize SDL:  %s\n",
#                SDL_GetError());
#
#        return 1;
#    }
#
#    atexit(cleanup);
#
#    if(TTF_Init() == -1) {
#        fprintf(stderr,
#                "\nTTF_Init Error:  %s\n",
#                SDL_GetError());
#        exit(1);
#    }
#
#    init_graphics();
#
#    initTetris();
#
#    bool quit = false;
#    while(!quit) {
#
#        preRender();
#
#        getInput();
#
#        updateTetris();
#
#        updateRender();
#
#        // Set to ~60 fps.
#        // 1000 ms/ 60 fps = 1/16 s^2/frame
#        SDL_Delay(16);
#    }

flags = LibSDL2::INIT_TIMER | LibSDL2::INIT_VIDEO | LibSDL2::INIT_EVENTS
