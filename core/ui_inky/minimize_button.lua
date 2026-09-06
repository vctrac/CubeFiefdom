local Button = require"core.ui.button"

return function( scene, props, min_height)
    return Button.button(scene, props.show and "minimize" or "minimize_on", function(btn)
        props.show = not props.show
        if props.show then
            props.height = props.max_height
            btn.props.key = "minimize"
        else
            props.height = min_height
            btn.props.key = "minimize_on"
        end
    end)
end