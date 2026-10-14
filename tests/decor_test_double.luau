-- Translation-only adapter: real shipped loader runs in Luau, not native Roblox.
-- Model ScaleTo is ABSOLUTE relative to canonical scale, not multiplicative.
vecMeta.__sub = function(a,b) return vector(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
vecMeta.__mul = function(a,b) return vector(a.X*b,a.Y*b,a.Z*b) end
local cfMeta = {__add=function(cf,v) return CFrame.new(cf.Position+v) end}
CFrame.new = function(pos) return setmetatable({Position=pos},cfMeta) end
local warnings = {}
local function warn(message) table.insert(warnings,message) end
local function decorNode(name, parent)
    local node={Name=name,Parent=parent,attrs={}}
    function node:SetAttribute(k,v) self.attrs[k]=v end
    function node:GetAttribute(k) return self.attrs[k] end
    function node:IsDescendantOf(ancestor)
        local p=self.Parent
        while p do if p==ancestor then return true end; p=p.Parent end
        return false
    end
    function node:Destroy() self.dead=true; self.Parent=nil end
    return node
end
Instance.new = function(class) return decorNode(class,nil) end
local function decorModel(scale, offset)
    local model=decorNode("ImportedTree",nil)
    model.scale=scale; model.pivot=vector(50,30,-20); model.offset=offset
    model.part=newPart("Mesh")
    function model:IsA(c) return c=="Model" end
    function model:GetDescendants() return {self.part} end
    function model:GetScale() return self.scale end
    function model:GetExtentsSize() return vector(2*self.scale,6*self.scale,2*self.scale) end
    function model:GetBoundingBox() return CFrame.new(self.pivot+self.offset*self.scale),self:GetExtentsSize() end
    function model:GetPivot() return CFrame.new(self.pivot) end
    function model:ScaleTo(s) self.scale=s end
    function model:PivotTo(cf) self.pivot=cf.Position end
    return model
end
local function near(a,b,message) assert(math.abs(a-b)<0.00001,message or (tostring(a).." != "..tostring(b))) end
