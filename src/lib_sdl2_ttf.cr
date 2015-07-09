@[Link("SDL2_ttf")]
lib LibSDL2_TTF
  alias Font = Void*

  fun init = TTF_Init() : Int32
  fun quit = TTF_Quit() : Void
  fun open_font = TTF_OpenFont(file : UInt8*, ptsize : Int32) : Font*
  fun render_text_blended = TTF_RenderText_Blended(font : Font*, text : UInt8*, fg : LibSDL2::Color) : LibSDL2::Surface*
  fun render_text_solid = TTF_RenderText_Solid(font : Font*, text : UInt8*, fg : LibSDL2::Color) : LibSDL2::Surface*
end
