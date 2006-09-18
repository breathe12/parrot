# Copyright (C) 2006, The Perl Foundation.
# $Id: mandel.pir 12835 2006-05-30 13:32:26Z coke $

=head1 TITLE

sdl/mandel.pir - Display Mandelbrot Set Using SDL

=head1 SYNOPSIS

To run this file, run the following command from the Parrot directory:

  $ ./parrot examples/sdl/mandel.pir [ options ]

=head2 Options

  --quit, -q      ... quit immediately (useful for benchmarking)

=head1 KEYBOARD COMMANDS

  q  ... quit application

=cut

.sub _main :main
    .param pmc argv
    .local pmc opts, app, event, handler
    'load_libs'()
    opts = 'get_opts'(argv)
    app  = 'make_app'()
    app.'calc'()
    $I0 = opts['quit']
    if $I0 goto ex
    event = getattribute app, 'event'
    handler = getattribute app, 'event_handler'
    event.'process_events'(handler, app)
ex:
    app.'quit'()
.end    

# utils
.sub 'load_libs'    
    # load the necessary libraries
    load_bytecode "library/SDL/App.pir"
    load_bytecode "library/SDL/Rect.pir"
    load_bytecode "library/SDL/Color.pir"
    load_bytecode "library/SDL/EventHandler.pir"
    load_bytecode "library/SDL/Event.pir"
    load_bytecode "library/Getopt/Obj.pir"
.end

# cmd line processing
.sub 'get_opts'
    .param pmc argv
    .local pmc opts, getopts
    getopts = new 'Getopt::Obj'
    push getopts, "quit|q"
    $S0 = shift argv
    opts = getopts."get_options"(argv)
    .return (opts)
.end

# create the application
.sub 'make_app'
    # create an SDL::App subclass
    .local pmc app, cl
    cl = subclass 'SDL::App', 'Mandel'
    addattribute cl, 'xstart'
    addattribute cl, 'ystart'
    addattribute cl, 'scale'
    addattribute cl, 'rect'
    addattribute cl, 'raw_palette'
    addattribute cl, 'event'
    addattribute cl, 'event_handler'
    # instantiate, seel also __init below
    app = new 'Mandel'
    .return (app)
.end    

.namespace ['Mandel']

# init the Mandel app instance
.sub __init :method
    .local int w, h
    .local float scale, xstart, ystart
    # mandelbrot set is witdh [-2, 0.25] heigth [ -1, 1]
    # round up, scale *200
    xstart = -2.0
    ystart = -1.0
    scale = 200
    w = 600
    h = 400
    self.'init'( 'height' => h, 'width' => w, 'bpp' => 0, 'flags' => 1 )
    $P0 = new .Float
    $P0 = xstart
    setattribute self, 'xstart', $P0
    $P0 = new .Float
    $P0 = ystart
    setattribute self, 'ystart', $P0
    $P0 = new .Float
    $P0 = scale
    setattribute self, 'scale', $P0

    .local pmc rect, main_screen
    main_screen = self.'surface'()

    # create an SDL::Rect representing the entire main screen
    .local pmc rect
    rect = new 'SDL::Rect'
    rect.'init'( 'height' => h, 'width' => w, 'x' => 0, 'y' => 0 )
    setattribute self, 'rect', rect

    .local pmc palette, raw_palette, black
    palette = self.'create_palette'()
    raw_palette = self.'create_rawpalette'(palette)
    setattribute self, 'raw_palette', raw_palette
    # draw the background
    black = palette[0]
    main_screen.'fill_rect'( rect, black )
    main_screen.'update_rect'( rect )

    self.'init_events'()
.end

.sub 'calc' :method
    .local pmc main_screen, raw_palette, rect, raw_surface
    .local int w, h, x, y, pal_elems, raw_c, k
    .local float xstart, ystart, scale
    # fetch the SDL::Surface representing the main window
    main_screen = self.'surface'()
    h = main_screen.'height'()
    w = main_screen.'width'()
    # lock the raw framebuffer
    $P0 = getattribute self, 'xstart'
    xstart = $P0
    $P0 = getattribute self, 'ystart'
    ystart = $P0
    $P0 = getattribute self, 'scale'
    scale = $P0
    raw_palette = getattribute self, 'raw_palette'
    rect        = getattribute self, 'rect'
    pal_elems = elements raw_palette
    # prefetch raw_surface
    raw_surface = main_screen.'surface'()
    # start calculation
    .local float z, Z, t, c, C, zz, ZZ
    .local int offs_y
    main_screen.'lock'()
    y = 0
loop_y:
    offs_y = w * y
    C = y / scale	# Im c part
    C += ystart
    x = 0
loop_x:
    c = x / scale   # re c part
    c += xstart 
    z = 0.0
    Z = 0.0   # Z(0) = 0
    k = 0
    # iteration loop, calculate
    # Z(k+1) = Z(k)^2 + c
    # bailout if abs(Z) > 2 or iteration limit of k is exceeded
    zz = 0.0  # z*z
    ZZ = 0.0  # Z*Z
loop_k:
    # z = zz - ZZ + c
    t = zz - ZZ
    t += c

    # Z = 2*z*Z + C
    Z *= 2.0
    Z *= z
    Z += C

    # z = t
    z = t

    # if (z*z + Z*Z > 4) break;
    zz = z * z
    ZZ = Z * Z
    $N1 = zz + ZZ
    if $N1 > 4.0 goto set_pix
    inc k
    if k < 200 goto loop_k	# iterations
    k = 0
set_pix:
    $I0 = k % pal_elems
    raw_c = raw_palette[$I0]
    $I0 = offs_y + x
    # main_screen.'draw_pixel'(x, y, raw_c)
    # -> opt
    raw_surface[ 'pixels'; 'array'; $I0 ] = raw_c
    inc x
    if x < w goto loop_x
    # update the screen on each line
    main_screen.'update_rect'( rect )
    inc y
    if y < h goto loop_y

    main_screen.'unlock'()
.end

# init event system
.sub 'init_events' :method
    .local pmc event, args, event_handler
    event = new 'SDL::Event'
    event.'init'()
    setattribute self, 'event', event

    $P0 = subclass 'SDL::EventHandler', ['Mandel'; 'EventHandler']
    event_handler = new ['Mandel'; 'EventHandler']
    event_handler.'init'(self)	# XXX unused
    setattribute self, 'event_handler', event_handler
.end

# sort by adding raw r+g+b values
.sub bright
    .param pmc l
    .param pmc r
    .local int cr, cl, br_l, br_r
    cl = l
    br_l = cl & 0xff
    cl >>= 8
    $I0 = cl & 0xff
    br_l += $I0
    cl >>= 8
    $I0 = cl & 0xff
    br_l += $I0
    cr = r
    br_r = cr & 0xff
    cr >>= 8
    $I0 = cr & 0xff
    br_r += $I0
    cr >>= 8
    $I0 = cr & 0xff
    br_r += $I0
    $I0 = cmp br_l, br_r
    .return ($I0)
.end

# create a 8x8x8 palette
.sub create_palette :method
    .local pmc palette, col, main_screen
    main_screen = self.'surface'()
    .local int r, g, b, color_type
    find_type  color_type, 'SDL::Color'
    palette = new .ResizablePMCArray
    r = 0
loop_r:
    g = 0
loop_g:    
    b = 0
loop_b:    
    col = new color_type
    col.'init'( 'r' => r, 'g' => g, 'b' => b )
    push palette, col
    b += 36
    if b <= 255 goto loop_b
    g += 36
    if g <= 255 goto loop_g
    r += 36
    if r <= 255 goto loop_r
    .const .Sub by_bright = "bright"
    # palette.'sort'(by_bright)
    .return (palette)
.end

# create raw_palette with surface colors
.sub create_rawpalette :method
    .param pmc palette
    .local int i, n, raw_c
    .local pmc raw_palette, col, main_screen
    main_screen = self.'surface'()
    n = elements palette
    raw_palette = new .FixedIntegerArray
    raw_palette = n
    i = 0
loop:    
    col = palette[i]
    raw_c = col.'color_for_surface'( main_screen )
    raw_palette[i] = raw_c
    inc i
    if i < n goto loop
    .return (raw_palette)
.end

.namespace ['Mandel'; 'EventHandler']

.sub key_down_q :method
    .param pmc app
    app.'quit'()
    end
.end

=head1 AUTHOR

leo

=head1 OPTIMIZATIONS

Runtimes for x86_64 AMD X2@2000
600 x 400 pixels,  200 iterations, 2s delay subtracted

=head2 Algorithm optimizations

Plain runcore and unoptimized parrot:

  Original version based on sdl/raw_pixels   21s
  Create raw_palette                         12s
  Prefetch raw_surface                       10s        [1]
  Optimize calculation loop (zz, ZZ)          9s        [2] 

=head2 Parrot based optimizations

Optimized build

  [2] plain runcore 64 bit                    3.0s
  [2] -C    runcore 64 bit                    1.5s
  [2] plain runcore 32 bit                    3.6s
  [2] -C    runcore 32 bit                    1.6s
  [1] -j                                      1.1s
  [2] -j                                      0.8s

=head1 SEE ALSO

L<http://en.wikipedia.org/wiki/Mandelbrot_set>

If you want faster mandelbrot with iteractive zooming use Xaos:

L<http://xaos.sourceforge.net/english.php>

=cut
