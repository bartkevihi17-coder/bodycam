local Config = {
	Camera = {
		BaseFov = 78,
		SprintFov = 84,
		FovLerpSpeed = 8,

		WalkBobFrequency = 10,
		SprintBobFrequency = 14,
		WalkBobAmplitude = 0.035,
		SprintBobAmplitude = 0.065,

		SwayStrength = 0.045,
		MaxSwayDegrees = 2.4,
		CameraRollDegrees = 1.4,
	},

	Movement = {
		WalkSpeed = 12,
		SprintSpeed = 20,
		CrouchSpeed = 6,
		CrouchHipOffset = -1.25,
	},

	Weapon = {
		Name = "G17",
		MagazineSize = 17,
		ReserveAmmo = 68,
		FireDelay = 0.12,
		ReloadTime = 1.6,
		Range = 600,
		Damage = 34,
		HeadshotMultiplier = 1.7,
	},
}

return Config
