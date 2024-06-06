const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const std = @import("std");
const assert = @import("std").debug.assert;

const State = struct {
    x: c_int,
    y: c_int,
    size: c_int,
    increase: bool,
};

var globalState = State{ .x = 0, .y = 0, .size = 0, .increase = true };

fn render(
    renderer: *c.SDL_Renderer,
) void {
    _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    _ = c.SDL_RenderClear(renderer);

    const rect = c.SDL_Rect{ .x = globalState.x, .y = globalState.y, .w = 10 + globalState.size, .h = 100 };

    _ = c.SDL_SetRenderDrawColor(renderer, 150, 70, 30, 255);
    _ = c.SDL_RenderDrawRect(renderer, &rect);
    _ = c.SDL_RenderFillRect(renderer, &rect);

    c.SDL_RenderPresent(renderer);
}

fn update() void {
    if (globalState.size >= 100) {
        globalState.increase = false;
    } else if (globalState.size <= 0) {
        globalState.increase = true;
    }

    if (globalState.increase) {
        globalState.size += 8;
    } else {
        globalState.size -= 2;
    }
}

fn move_left() void {
    if (globalState.x == 0) {
        return;
    }
    globalState.x -= 10;
}

fn move_right() void {
    globalState.x += 10;
}

fn move_up() void {
    if (globalState.y == 0) {
        return;
    }
    globalState.y -= 10;
}

fn move_down() void {
    globalState.y += 10;
}

pub fn main() !void {
    const windowHeight = 800;
    const windowWidth = 800;

    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const screen = c.SDL_CreateWindow("My Game Window", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, windowHeight, windowWidth, c.SDL_WINDOW_OPENGL) orelse
        {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(screen);

    const renderer = c.SDL_CreateRenderer(screen, -1, c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    const zig_bmp = @embedFile("zig.bmp");
    const rw = c.SDL_RWFromConstMem(zig_bmp, zig_bmp.len) orelse {
        c.SDL_Log("Unable to get RWFromConstMem: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer assert(c.SDL_RWclose(rw) == 0);

    const zig_surface = c.SDL_LoadBMP_RW(rw, 0) orelse {
        c.SDL_Log("Unable to load bmp: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_FreeSurface(zig_surface);

    const zig_texture = c.SDL_CreateTextureFromSurface(renderer, zig_surface) orelse {
        c.SDL_Log("Unable to create texture from surface: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyTexture(zig_texture);

    var quit = false;
    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                c.SDL_KEYDOWN => {
                    const key = event.key.keysym.sym;
                    switch (key) {
                        c.SDLK_ESCAPE => {
                            quit = true;
                        },
                        c.SDLK_LEFT => {
                            move_left();
                        },
                        c.SDLK_RIGHT => {
                            move_right();
                        },
                        c.SDLK_UP => {
                            move_up();
                        },
                        c.SDLK_DOWN => {
                            move_down();
                        },
                        else => {},
                    }
                },
                else => {},
            }
        }

        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderClear(renderer);

        render(renderer);
        update();
        // std.debug.print("Rendering {}\n", .{globalState.size});

        // c.SDL_Delay(6);
    }
}
