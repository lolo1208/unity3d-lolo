---@class UnityEngine.UI.Text : UnityEngine.UI.MaskableGraphic
---@field cachedTextGenerator UnityEngine.TextGenerator
---@field cachedTextGeneratorForLayout UnityEngine.TextGenerator
---@field mainTexture UnityEngine.Texture
---@field font UnityEngine.Font
---@field text string
---@field supportRichText bool
---@field resizeTextForBestFit bool
---@field resizeTextMinSize int
---@field resizeTextMaxSize int
---@field alignment UnityEngine.TextAnchor
---@field alignByGeometry bool
---@field fontSize int
---@field horizontalOverflow UnityEngine.HorizontalWrapMode
---@field verticalOverflow UnityEngine.VerticalWrapMode
---@field lineSpacing float
---@field fontStyle UnityEngine.FontStyle
---@field pixelsPerUnit float
---@field minWidth float
---@field preferredWidth float
---@field flexibleWidth float
---@field minHeight float
---@field preferredHeight float
---@field flexibleHeight float
---@field layoutPriority int
local m = {}
---@param endValue UnityEngine.Color
---@param duration float
---@return DG.Tweening.Tweener
function m:DOColor(endValue, duration) end
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DOFade(endValue, duration) end
---@param endValue string
---@param duration float
---@param richTextEnabled bool
---@param scrambleMode DG.Tweening.ScrambleMode
---@param scrambleChars string
---@return DG.Tweening.Tweener
function m:DOText(endValue, duration, richTextEnabled, scrambleMode, scrambleChars) end
---@param endValue UnityEngine.Color
---@param duration float
---@return DG.Tweening.Tweener
function m:DOBlendableColor(endValue, duration) end
function m:FontTextureChanged() end
---@param extents UnityEngine.Vector2
---@return UnityEngine.TextGenerationSettings
function m:GetGenerationSettings(extents) end
---@param anchor UnityEngine.TextAnchor
---@return UnityEngine.Vector2
function m.GetTextAnchorPivot(anchor) end
function m:CalculateLayoutInputHorizontal() end
function m:CalculateLayoutInputVertical() end
UnityEngine = {}
UnityEngine.UI = {}
UnityEngine.UI.Text = m
return m