# fig_tools

Figure layout, axes linking, interactive controls — the plumbing for good-looking multi-panel MATLAB figures.

Part of the Prerau Lab [`utils`](https://github.com/preraulab/utils) meta-repository. Can also be used standalone.

## Layout

| Task | Use |
|---|---|
| Lay out an M × N grid with controlled margins | `figdesign` |
| Open a full-screen figure | `fullfig` |
| Add panel labels (A, B, C, …) | `letter_label` |
| Add a figure-level title/labels across subplots | `outertitle`, `outerlabels` |
| Merge multiple figures into one | `mergefigures` |
| Prep a figure for print / page export | `pagefig` |
| Find the most-square subplot grid for N panels | `squarest_subplots` |

## Axes linking & limits

| Task | Use |
|---|---|
| Link color axes across a set of axes | `linkcaxes` |
| Link 3-D camera + xyz limits across axes | `linkaxes3d` |
| Match X/Y limits across axes | `equalize_axes` |
| Scale color limits to an inner percentile | `climscale` |
| Set color limits manually | `clims` |

## Colorbars & annotations

| Task | Use |
|---|---|
| Colorbar that doesn't resize the parent axes | `colorbar_noresize` |
| Colorbar along the top | `topcolorbar` |
| Scale bar on an axis | `scaleline` |
| Shadow / secondary axis | `shadow_axis` |
| Split an axis into multiple panels | `split_axis` |

## Interaction

| Task | Use |
|---|---|
| Interactive scroll/zoom/pan with mouse + keyboard | `scrollzoompan` |
| Capture user clicks on a figure | `get_clicks` |
| Slice picker UI | `slicepopup` |
| Zoom so content fills the axes | `zoom_fill` |
| Build a stacked-plot control | `stacked_plot` |

## Example

```matlab
ax = figdesign(2, 3, 'margins', [0.05 0.05 0.05 0.05 0.05]);
for k = 1:6
    axes(ax(k));
    imagesc(peaks(100) + randn(100));
end
linkcaxes(ax);
climscale(ax, 0.01);
letter_label(ax, 'A', 'TopLeft');
scrollzoompan(ax(1), 'x');
```

## Function list

`clims`, `climscale`, `colorbar_noresize`, `equalize_axes`, `figdesign`, `fullfig`, `get_clicks`, `letter_label`, `linkaxes3d`, `linkcaxes`, `mergefigures`, `outerlabels`, `outertitle`, `pagefig`, `scaleline`, `scrollzoompan`, `shadow_axis`, `slicepopup`, `split_axis`, `squarest_subplots`, `stacked_plot`, `topcolorbar`, `zoom_fill`

See `help <function>` at the MATLAB prompt for the full docstring of each.

## Install

```matlab
addpath('/path/to/fig_tools');
```

## Dependencies

MATLAB R2020a+. No required toolboxes.

## License

BSD 3-Clause. See [`LICENSE`](LICENSE).
