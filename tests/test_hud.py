import unittest,subprocess
from test_map_geometry import ADAPTER,ROOT,LUAU
class HUDTests(unittest.TestCase):
    def test_hud_touch_keyboard_feedback_and_checkpoint(self):
        source=ADAPTER+r'''
UDim2.new=function(x,xo,y,yo) return {X={Scale=x,Offset=xo},Y={Scale=y,Offset=yo}} end
UDim={new=function(...) return {...} end}
local function signal() return {Connect=function(self,fn) self.fn=fn end,Fire=function(self,...) self.fn(...) end} end
local stage={Value=1,Changed=signal()}; local coins={Value=0,Changed=signal()}
local leader={WaitForChild=function(_,n) return n=="Stage" and stage or coins end}
local pg=Instance.new("Folder")
local p={WaitForChild=function(_,n) return n=="PlayerGui" and pg or leader end}
local touch=true
local input={TouchEnabled=true,LastInputTypeChanged=signal(),GetLastInputType=function() return Enum.UserInputType.Touch end}
game={GetService=function(_,n) return n=="Players" and {LocalPlayer=p} or input end}
'''
        source+='\nlocal HUD=(function()\n'+(ROOT/'src/client/controllers/HUDController.luau').read_text()+'\nend)()\n'
        source+=r'''
HUD.start()
local gui=pg:FindFirstChild("ObbyHUD")
local frame=gui:FindFirstChild("MainFrame")
assert(frame,"missing HUD main frame")
local cp=frame:FindFirstChild("CheckpointLabel"); assert(cp and string.find(cp.Text,"CP1"),"active checkpoint missing")
local tutorial=gui:FindFirstChild("TutorialFrame"); assert(tutorial and not tutorial.Active,"touch input blocked")
local text=tutorial:FindFirstChild("TutorialText")
assert(string.find(text.Text,"layar"),"touch tutorial missing")
input.LastInputTypeChanged:Fire(Enum.UserInputType.Keyboard)
assert(string.find(text.Text,"Space"),"keyboard binding missing")
stage.Value=2; stage.Changed:Fire(2)
assert(string.find(cp.Text,"CP2") and string.find(text.Text,"aktif"),"CP2 feedback missing")
HUD.start(); assert(#pg:GetChildren()==1,"HUD duplicates")
'''
        target=ROOT/'build/test_hud.luau'; target.write_text(source)
        result=subprocess.run([LUAU,str(target)],capture_output=True,text=True)
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)
