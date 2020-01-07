
uniform float normalSize;
uniform bool doMultiframe;
uniform bool doStrokeEndpoints;
uniform float gpEditOpacity;
uniform vec4 gpEditColor;

in vec3 pos;
in float ma;
in uint vflag;

out vec4 finalColor;

void discard_vert()
{
  /* We set the vertex at the camera origin to generate 0 fragments. */
  gl_Position = vec4(0.0, 0.0, -3e36, 0.0);
}

#define GP_EDIT_POINT_SELECTED (1u << 0u)
#define GP_EDIT_STROKE_SELECTED (1u << 1u)
#define GP_EDIT_MULTIFRAME (1u << 2u)
#define GP_EDIT_STROKE_START (1u << 3u)
#define GP_EDIT_STROKE_END (1u << 4u)

#ifdef USE_POINTS
#  define colorUnselect colorGpencilVertex
#else
#  define colorUnselect gpEditColor
#endif

void main()
{
  GPU_INTEL_VERTEX_SHADER_WORKAROUND

  vec3 world_pos = point_object_to_world(pos);
  gl_Position = point_world_to_ndc(world_pos);

  bool is_multiframe = (vflag & GP_EDIT_MULTIFRAME) != 0u;
  bool is_stroke_sel = (vflag & GP_EDIT_STROKE_SELECTED) != 0u;
  bool is_point_sel = (vflag & GP_EDIT_POINT_SELECTED) != 0u;
  finalColor = (is_point_sel) ? colorGpencilVertexSelect : colorUnselect;
  finalColor.a *= gpEditOpacity;

#ifdef USE_POINTS
  gl_PointSize = sizeVertex * 2.0;

  if (doStrokeEndpoints) {
    bool is_stroke_start = (vflag & GP_EDIT_STROKE_START) != 0u;
    bool is_stroke_end = (vflag & GP_EDIT_STROKE_END) != 0u;

    if (is_stroke_start) {
      gl_PointSize *= 2.0;
      finalColor.rgb = vec3(0.0, 1.0, 0.0);
    }
    else if (is_stroke_end) {
      gl_PointSize *= 1.5;
      finalColor.rgb = vec3(1.0, 0.0, 0.0);
    }
  }

  if (!is_stroke_sel || (!doMultiframe && is_multiframe)) {
    discard_vert();
  }
#endif

  if (ma == -1.0 || (is_multiframe && !doMultiframe)) {
    discard_vert();
  }

#ifdef USE_WORLD_CLIP_PLANES
  world_clip_planes_calc_clip_distance(world_pos);
#endif
}
