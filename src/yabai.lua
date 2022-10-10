---
--- DateTime: 10/5/22 7:18 PM
---

function focusOnAnyVisibleWindow()
    -- Focus any window that is current visible
    execTaskInShellAsync([[yabai -m window --focus $(yabai -m query --windows | jq -rj '. | map(select(.["is-visible"] == true)) | .[0].id')]])
end

function getFocusedWindowId()
    return execTaskInShellSync("yabai -m query --windows | jq -rj '. | map(select(.[\"has-focus\"] == true)) | .[0].id'")
end

function getAllFocusedWindows()
    return execTaskInShellSync("yabai -m query --windows | jq -rj '. | map(select(.[\"has-focus\"] == true)) | .'")
end

function getAllWindowsForFocusedApp()
    --echo $QUERY | jq -rj '. | map(select(.[\"app\"] == \"$APP\"")) | .';
    -- echo "$QUERY" | cat | jq -rj '. | map(select(.[\"has-focus\"] == true)) | .[0]["app"]';
    return execTaskInShellSync([=[
    QUERY=$(yabai -m query --windows);
    APP=$(echo "$QUERY" | jq -rj '. | map(select(.["has-focus"] == true)) | .[0]["app"]');
    echo "$QUERY" | jq -rj ". | map(select(.[\"app\"] == \"$APP\"))"
    ]=])
end

function moveWindowToSpace(space_sel)
    -- This call will hang hammerspoon if done on the main thread (https://github.com/koekeishiya/yabai/issues/502#issuecomment-633353477)
    -- so we need to call it using hs.task and we throw it in a coroutines so we can wait for the command to complete
    coroutine.wrap(function()
        local winId = getFocusedWindowId()
        local spacesLen = tonumber(execTaskInShellSync("yabai -m query --spaces | jq -rj '. | length'"))

        if spacesLen > 1 then
            execTaskInShellAsync("yabai -m window --space " .. space_sel):waitUntilExit()
            execTaskInShellAsync("yabai -m window --focus " .. winId)
        end
    end)()
end
