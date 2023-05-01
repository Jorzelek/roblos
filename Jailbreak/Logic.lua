local Ce1650f7ed = {}
do
	local Pdf9625, y76ab8, Uc6a3f4 = math.exp, math.cos, math.sin
	local u56df045 = 1.0E-4
	local function F3e90307dbc(fdfa3a0e9)
		local Z7f7f2ba0c1 = tick()
		local Zba403aa07 = Z7f7f2ba0c1 - fdfa3a0e9.t
		local N87ced, yc11e8f14134 = fdfa3a0e9.Freq, fdfa3a0e9.Damp
		local Z3c2f33f, F3224596870, V46a9cd = fdfa3a0e9.p, fdfa3a0e9.v, fdfa3a0e9.Target
		local I9ea231 = Z3c2f33f - V46a9cd
		local M6ba3e = F3224596870
		if yc11e8f14134 > 1 then
			local d5c341 = -N87ced * yc11e8f14134
			local Xcc419e0 = N87ced * (yc11e8f14134 * yc11e8f14134 - 1) ^ 0.5
			local B6f370 = d5c341 - Xcc419e0
			local o1e81b8fa67 = d5c341 + Xcc419e0
			local g3bc40344fc = Pdf9625(B6f370 * Zba403aa07)
			local u1ef86 = Pdf9625(o1e81b8fa67 * Zba403aa07)
			local Oc858b01c4 = (M6ba3e - I9ea231 * o1e81b8fa67) / (-2 * Xcc419e0)
			local mdc7641 = I9ea231 - Oc858b01c4
			Z3c2f33f = V46a9cd + Oc858b01c4 * g3bc40344fc + mdc7641 * u1ef86
			F3224596870 = Oc858b01c4 * B6f370 * g3bc40344fc + mdc7641 * o1e81b8fa67 * u1ef86
		elseif yc11e8f14134 == 1 then
			local fdeb9cb80 = Pdf9625(-N87ced * Zba403aa07)
			local rb6b8f09 = M6ba3e + N87ced * I9ea231
			local M9cb9c22c418 = I9ea231
			local qe01bb0e8 = (rb6b8f09 * Zba403aa07 + M9cb9c22c418) * fdeb9cb80
			Z3c2f33f = V46a9cd + qe01bb0e8
			F3224596870 = rb6b8f09 * fdeb9cb80 - qe01bb0e8 * N87ced
		else
			local X3e3c2e81cd1 = N87ced * yc11e8f14134
			local h0561e6 = N87ced * (1 - yc11e8f14134 * yc11e8f14134) ^ 0.5
			local K8c6620dc569 = Pdf9625(-X3e3c2e81cd1 * Zba403aa07)
			local q2d69c9d = y76ab8(h0561e6 * Zba403aa07)
			local j0ac1525 = Uc6a3f4(h0561e6 * Zba403aa07)
			local X64e4930f0 = I9ea231
			local rcda77d9ef = (M6ba3e + X3e3c2e81cd1 * X64e4930f0) / h0561e6
			Z3c2f33f = V46a9cd + K8c6620dc569 * (X64e4930f0 * q2d69c9d + rcda77d9ef * j0ac1525)
			F3224596870 = -K8c6620dc569 * ((X64e4930f0 * X3e3c2e81cd1 - rcda77d9ef * h0561e6) * q2d69c9d + (X64e4930f0 * h0561e6 + rcda77d9ef * X3e3c2e81cd1) * j0ac1525)
		end
		return Z3c2f33f, F3224596870
	end
	local function G81ac9(led415, V55c09cf)
		local v933ed5076, P3722bcee = F3e90307dbc(led415)
		led415.p, led415.v = v933ed5076, P3722bcee
		led415.Target = V55c09cf
		led415.t = tick()
		return v933ed5076, P3722bcee
	end
	local function qbc995b(I058b6d, Vdff28a67a5)
		local o90f45, A0eab8e2a6 = F3e90307dbc(I058b6d)
		I058b6d.t = tick()
		I058b6d.p, I058b6d.v = o90f45, A0eab8e2a6 + Vdff28a67a5
	end
	local function w10bfee25f5()
		return {
			p = nil,
			v = nil,
			Target = nil,
			Damp = nil,
			Freq = nil,
			t = tick(),
			Update = F3e90307dbc,
			SetTarget = G81ac9,
			Accelerate = qbc995b
		}
	end
	Ce1650f7ed.MakeSpring = w10bfee25f5
	Ce1650f7ed.SpringUpdate = F3e90307dbc
end
do
	local K3fa7c9 = CFrame.new
	local Ra34b14 = K3fa7c9()
	local Cbe213188edf, c38d6c7 = math.cos, math.sin
	local p374ce85 = Ra34b14.pointToObjectSpace
	local function Ja8976ae(D4a18badb6cd)
		local I390d9171eb2, X174d0, x75ff6e8799 = D4a18badb6cd.x, D4a18badb6cd.y, D4a18badb6cd.z
		local Ed21fad28 = (I390d9171eb2 * I390d9171eb2 + X174d0 * X174d0 + x75ff6e8799 * x75ff6e8799) ^ 0.5
		if Ed21fad28 > 1.0E-5 then
			local E28296 = c38d6c7(Ed21fad28 * 0.5) / Ed21fad28
			return K3fa7c9(0, 0, 0, E28296 * I390d9171eb2, E28296 * X174d0, E28296 * x75ff6e8799, Cbe213188edf(Ed21fad28 * 0.5))
		else
			return Ra34b14
		end
	end
	local function rfeb68(K1b8c756, gc6b418, F0d4c66a9568, Vf6ac93, A9c5d57ec37)
		local m85114d8ce = p374ce85(F0d4c66a9568, Vf6ac93)
		local Me4311, Xd9d0f2c24, qefe8e222b0 = m85114d8ce.x, m85114d8ce.y, m85114d8ce.z
		local aeb529ebd = (Me4311 * Me4311 + Xd9d0f2c24 * Xd9d0f2c24 + qefe8e222b0 * qefe8e222b0) ^ 0.5
		local q7a40b83eaf, z92a351, xfb44a = Me4311 / aeb529ebd, Xd9d0f2c24 / aeb529ebd, qefe8e222b0 / aeb529ebd
		aeb529ebd = aeb529ebd > K1b8c756 + gc6b418 and K1b8c756 + gc6b418 or aeb529ebd
		local G6d36d = (gc6b418 * gc6b418 - K1b8c756 * K1b8c756 - aeb529ebd * aeb529ebd) / (2 * K1b8c756 * aeb529ebd)
		local k6bd9a = 1 - G6d36d * G6d36d
		if k6bd9a < 0 then
			return false
		end
		local F544721b = k6bd9a ^ 0.5
		local K40a62272c = (2 * (1 + F544721b * z92a351 + G6d36d * xfb44a)) ^ 0.5
		local m93032c06, J265b9541d8, Qc01f7cb58c, Qbee54 = K40a62272c * 0.5, (F544721b * xfb44a - G6d36d * z92a351) / K40a62272c, G6d36d * q7a40b83eaf / K40a62272c, -F544721b * q7a40b83eaf / K40a62272c
		if A9c5d57ec37 then
			local a9f7cef5, Mbba014902 = Cbe213188edf(A9c5d57ec37 * 0.5), c38d6c7(A9c5d57ec37 * 0.5)
			m93032c06, J265b9541d8, Qc01f7cb58c, Qbee54 = a9f7cef5 * m93032c06 - Mbba014902 * (q7a40b83eaf * J265b9541d8 + z92a351 * Qc01f7cb58c + xfb44a * Qbee54), a9f7cef5 * J265b9541d8 + Mbba014902 * (q7a40b83eaf * m93032c06 - xfb44a * Qc01f7cb58c + z92a351 * Qbee54), a9f7cef5 * Qc01f7cb58c + Mbba014902 * (z92a351 * m93032c06 + xfb44a * J265b9541d8 - q7a40b83eaf * Qbee54), a9f7cef5 * Qbee54 + Mbba014902 * (xfb44a * m93032c06 - z92a351 * J265b9541d8 + q7a40b83eaf * Qc01f7cb58c)
		end
		local w0b85dee = (aeb529ebd * G6d36d + K1b8c756) / (aeb529ebd * aeb529ebd + 2 * aeb529ebd * G6d36d * K1b8c756 + K1b8c756 * K1b8c756) ^ 0.5
		local M6448f = ((1 - w0b85dee) * 0.5) ^ 0.5
		local v5cf3a3c7e = ((1 + w0b85dee) * 0.5) ^ 0.5
		return F0d4c66a9568 * K3fa7c9(-K1b8c756 * 2 * (J265b9541d8 * Qbee54 + Qc01f7cb58c * m93032c06), K1b8c756 * 2 * (J265b9541d8 * m93032c06 - Qc01f7cb58c * Qbee54), K1b8c756 * (2 * (J265b9541d8 * J265b9541d8 + Qc01f7cb58c * Qc01f7cb58c) - 1), M6448f * J265b9541d8 + v5cf3a3c7e * m93032c06, M6448f * Qc01f7cb58c + v5cf3a3c7e * Qbee54, M6448f * Qbee54 - v5cf3a3c7e * Qc01f7cb58c, M6448f * m93032c06 - v5cf3a3c7e * J265b9541d8), F0d4c66a9568 * K3fa7c9(0, 0, 0, J265b9541d8, Qc01f7cb58c, Qbee54, m93032c06)
	end
	local I2d32cd1072 = rfeb68
	Ce1650f7ed.FromAxisAngle = Ja8976ae
	Ce1650f7ed.SolveIK = I2d32cd1072
end
do
	local u83075b = Vector3.new().Dot
	local V8b4aad6, saedba = math.min, math.max
	local Y2e086d = CFrame.new().components
	local x8080a8b = math.abs
	local function k3f5564(O0231e, m649ba543a17, j041a7a8, K4c3c2f05, Nd81e7095e6)
		local ta1c23, ad686e12, A576e7f1f, g15e5a, b4003a4a9306, E7658283181e, icfa22c, fa308de1, M1e63c737325
		if j041a7a8 then
			ta1c23, ad686e12, A576e7f1f = j041a7a8.x, j041a7a8.y, j041a7a8.z
		else
			ta1c23, ad686e12, A576e7f1f = 1, 0, 0
		end
		if K4c3c2f05 then
			g15e5a, b4003a4a9306, E7658283181e = K4c3c2f05.x, K4c3c2f05.y, K4c3c2f05.z
		else
			g15e5a, b4003a4a9306, E7658283181e = 0, 1, 0
		end
		if Nd81e7095e6 then
			icfa22c, fa308de1, M1e63c737325 = Nd81e7095e6.x, Nd81e7095e6.y, Nd81e7095e6.z
		else
			icfa22c, fa308de1, M1e63c737325 = 0, 0, 1
		end
		local S8d0354a6, J83937c, S8d769c34, q4eb04, Ra58794, Of4ed5e6b3, o5fccd, S1a0c14e, M3058014aa1, d241d0a47c, H0d7921d3, C72aa48d07d3 = Y2e086d(O0231e)
		local Yb386625f68, H9b8ab4, Q50eab1 = 0.5 * m649ba543a17.x, 0.5 * m649ba543a17.y, 0.5 * m649ba543a17.z
		local Jb56fc6d, C02a89ca8, H01871a4c, E989c15e15, l2554e, Ue306a67, V4e31dd6a90f, N47fb9, Y45bbe3, E42f924516, U3a3706d887, De4d049eac1, Ee1f0ec, p0cdbd40c0, M4a9f8b422d, m5d661, f9340bc7ab54, V29088d79a4, e0ab8752cb, J3978a0ea, C30530e88b, jdb30286d52d, B7d8043b6, Yd58a8aba = S8d0354a6 - q4eb04 * Yb386625f68 - Ra58794 * H9b8ab4 - Of4ed5e6b3 * Q50eab1, J83937c - o5fccd * Yb386625f68 - S1a0c14e * H9b8ab4 - M3058014aa1 * Q50eab1, S8d769c34 - d241d0a47c * Yb386625f68 - H0d7921d3 * H9b8ab4 - C72aa48d07d3 * Q50eab1, S8d0354a6 - q4eb04 * Yb386625f68 - Ra58794 * H9b8ab4 + Of4ed5e6b3 * Q50eab1, J83937c - o5fccd * Yb386625f68 - S1a0c14e * H9b8ab4 + M3058014aa1 * Q50eab1, S8d769c34 - d241d0a47c * Yb386625f68 - H0d7921d3 * H9b8ab4 + C72aa48d07d3 * Q50eab1, S8d0354a6 - q4eb04 * Yb386625f68 + Ra58794 * H9b8ab4 - Of4ed5e6b3 * Q50eab1, J83937c - o5fccd * Yb386625f68 + S1a0c14e * H9b8ab4 - M3058014aa1 * Q50eab1, S8d769c34 - d241d0a47c * Yb386625f68 + H0d7921d3 * H9b8ab4 - C72aa48d07d3 * Q50eab1, S8d0354a6 - q4eb04 * Yb386625f68 + Ra58794 * H9b8ab4 + Of4ed5e6b3 * Q50eab1, J83937c - o5fccd * Yb386625f68 + S1a0c14e * H9b8ab4 + M3058014aa1 * Q50eab1, S8d769c34 - d241d0a47c * Yb386625f68 + H0d7921d3 * H9b8ab4 + C72aa48d07d3 * Q50eab1, S8d0354a6 + q4eb04 * Yb386625f68 - Ra58794 * H9b8ab4 - Of4ed5e6b3 * Q50eab1, J83937c + o5fccd * Yb386625f68 - S1a0c14e * H9b8ab4 - M3058014aa1 * Q50eab1, S8d769c34 + d241d0a47c * Yb386625f68 - H0d7921d3 * H9b8ab4 - C72aa48d07d3 * Q50eab1, S8d0354a6 + q4eb04 * Yb386625f68 - Ra58794 * H9b8ab4 + Of4ed5e6b3 * Q50eab1, J83937c + o5fccd * Yb386625f68 - S1a0c14e * H9b8ab4 + M3058014aa1 * Q50eab1, S8d769c34 + d241d0a47c * Yb386625f68 - H0d7921d3 * H9b8ab4 + C72aa48d07d3 * Q50eab1, S8d0354a6 + q4eb04 * Yb386625f68 + Ra58794 * H9b8ab4 - Of4ed5e6b3 * Q50eab1, J83937c + o5fccd * Yb386625f68 + S1a0c14e * H9b8ab4 - M3058014aa1 * Q50eab1, S8d769c34 + d241d0a47c * Yb386625f68 + H0d7921d3 * H9b8ab4 - C72aa48d07d3 * Q50eab1, S8d0354a6 + q4eb04 * Yb386625f68 + Ra58794 * H9b8ab4 + Of4ed5e6b3 * Q50eab1, J83937c + o5fccd * Yb386625f68 + S1a0c14e * H9b8ab4 + M3058014aa1 * Q50eab1, S8d769c34 + d241d0a47c * Yb386625f68 + H0d7921d3 * H9b8ab4 + C72aa48d07d3 * Q50eab1
		local R32df87f, q9f516198df, Be5a3f8b, Hf806795199, t0220947, J9a7c96, X5aa43ae, Sc10a89f76da, k7858b88bec, H7d773, Ifdc33f, o6f335aa, r349cd0, Q4f7a4aeb, H48a80, l1ba506ff, n922b18e7, y31ef39cca, G599dff92, r754cb7, s86ef322e6a7, K8aac7d3caa, J41f6e, F013370 = ta1c23 * Jb56fc6d + ad686e12 * C02a89ca8 + A576e7f1f * H01871a4c, ta1c23 * E989c15e15 + ad686e12 * l2554e + A576e7f1f * Ue306a67, ta1c23 * V4e31dd6a90f + ad686e12 * N47fb9 + A576e7f1f * Y45bbe3, ta1c23 * E42f924516 + ad686e12 * U3a3706d887 + A576e7f1f * De4d049eac1, ta1c23 * Ee1f0ec + ad686e12 * p0cdbd40c0 + A576e7f1f * M4a9f8b422d, ta1c23 * m5d661 + ad686e12 * f9340bc7ab54 + A576e7f1f * V29088d79a4, ta1c23 * e0ab8752cb + ad686e12 * J3978a0ea + A576e7f1f * C30530e88b, ta1c23 * jdb30286d52d + ad686e12 * B7d8043b6 + A576e7f1f * Yd58a8aba, g15e5a * Jb56fc6d + b4003a4a9306 * C02a89ca8 + E7658283181e * H01871a4c, g15e5a * E989c15e15 + b4003a4a9306 * l2554e + E7658283181e * Ue306a67, g15e5a * V4e31dd6a90f + b4003a4a9306 * N47fb9 + E7658283181e * Y45bbe3, g15e5a * E42f924516 + b4003a4a9306 * U3a3706d887 + E7658283181e * De4d049eac1, g15e5a * Ee1f0ec + b4003a4a9306 * p0cdbd40c0 + E7658283181e * M4a9f8b422d, g15e5a * m5d661 + b4003a4a9306 * f9340bc7ab54 + E7658283181e * V29088d79a4, g15e5a * e0ab8752cb + b4003a4a9306 * J3978a0ea + E7658283181e * C30530e88b, g15e5a * jdb30286d52d + b4003a4a9306 * B7d8043b6 + E7658283181e * Yd58a8aba, icfa22c * Jb56fc6d + fa308de1 * C02a89ca8 + M1e63c737325 * H01871a4c, icfa22c * E989c15e15 + fa308de1 * l2554e + M1e63c737325 * Ue306a67, icfa22c * V4e31dd6a90f + fa308de1 * N47fb9 + M1e63c737325 * Y45bbe3, icfa22c * E42f924516 + fa308de1 * U3a3706d887 + M1e63c737325 * De4d049eac1, icfa22c * Ee1f0ec + fa308de1 * p0cdbd40c0 + M1e63c737325 * M4a9f8b422d, icfa22c * m5d661 + fa308de1 * f9340bc7ab54 + M1e63c737325 * V29088d79a4, icfa22c * e0ab8752cb + fa308de1 * J3978a0ea + M1e63c737325 * C30530e88b, icfa22c * jdb30286d52d + fa308de1 * B7d8043b6 + M1e63c737325 * Yd58a8aba
		local H16476f, M61fba761ea, D87042, Fcab2f24f6, y4fef0f, b91044ed249 = V8b4aad6(R32df87f, q9f516198df, Be5a3f8b, Hf806795199, t0220947, J9a7c96, X5aa43ae, Sc10a89f76da), saedba(R32df87f, q9f516198df, Be5a3f8b, Hf806795199, t0220947, J9a7c96, X5aa43ae, Sc10a89f76da), V8b4aad6(k7858b88bec, H7d773, Ifdc33f, o6f335aa, r349cd0, Q4f7a4aeb, H48a80, l1ba506ff), saedba(k7858b88bec, H7d773, Ifdc33f, o6f335aa, r349cd0, Q4f7a4aeb, H48a80, l1ba506ff), V8b4aad6(n922b18e7, y31ef39cca, G599dff92, r754cb7, s86ef322e6a7, K8aac7d3caa, J41f6e, F013370), saedba(n922b18e7, y31ef39cca, G599dff92, r754cb7, s86ef322e6a7, K8aac7d3caa, J41f6e, F013370)
		return H16476f, M61fba761ea, D87042, Fcab2f24f6, y4fef0f, b91044ed249
	end
	local function mf577c(K1e0db97c, pcdcfad73a76)
		local c377d6bd071, c187369481, Zbac38d5 = Vector3.new(1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1)
		local v441a3bf2e, y20ad13, tb77589, K8b997bb3a, G74e97f, Nbe5d2f33 = k3f5564(K1e0db97c, pcdcfad73a76, c377d6bd071, c187369481, Zbac38d5)
		return CFrame.new(0.5 * (v441a3bf2e + y20ad13), 0.5 * (tb77589 + K8b997bb3a), 0.5 * (G74e97f + Nbe5d2f33), c377d6bd071.x, c187369481.x, Zbac38d5.x, c377d6bd071.y, c187369481.y, Zbac38d5.y, c377d6bd071.z, c187369481.z, Zbac38d5.z), Vector3.new(y20ad13 - v441a3bf2e, K8b997bb3a - tb77589, Nbe5d2f33 - G74e97f)
	end
	local function E9d5883b(mafaeca30, d02747c, Q814c569a115, pd3a8764ae7f)
		local q8552b25005, G29bd1425, nee7f220, mebee9e7d18, C501ddbe733f, J0ff369
		for K837ad8, R11a5e6 in next, mafaeca30, nil do
			local k225974e, A3acad9a = R11a5e6.CFrame, R11a5e6.Size
			local n499874735, C7d55c57c281, Pe9558, O7aaddac1, c2e19fa, G2328edee = k3f5564(k225974e, A3acad9a, d02747c, Q814c569a115, pd3a8764ae7f)
			if not q8552b25005 or q8552b25005 > n499874735 then
				q8552b25005 = n499874735
			end
			if not G29bd1425 or G29bd1425 < C7d55c57c281 then
				G29bd1425 = C7d55c57c281
			end
			if not nee7f220 or nee7f220 > Pe9558 then
				nee7f220 = Pe9558
			end
			if not mebee9e7d18 or mebee9e7d18 < O7aaddac1 then
				mebee9e7d18 = O7aaddac1
			end
			if not C501ddbe733f or C501ddbe733f > c2e19fa then
				C501ddbe733f = c2e19fa
			end
			if not J0ff369 or J0ff369 < G2328edee then
				J0ff369 = G2328edee
			end
		end
		return q8552b25005, G29bd1425, nee7f220, mebee9e7d18, C501ddbe733f, J0ff369
	end
	local function r12fab7(Nf302016d)
		local tcfcd2f, o304480d, s16510cc4 = Vector3.new(1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1)
		local bf5f11c, I2eece5, K3f44216, X2653c, N7d6367, t5c980 = E9d5883b(Nf302016d, tcfcd2f, o304480d, s16510cc4)
		return CFrame.new(0.5 * (bf5f11c + I2eece5), 0.5 * (K3f44216 + X2653c), 0.5 * (N7d6367 + t5c980), tcfcd2f.x, o304480d.x, s16510cc4.x, tcfcd2f.y, o304480d.y, s16510cc4.y, tcfcd2f.z, o304480d.z, s16510cc4.z), Vector3.new(I2eece5 - bf5f11c, X2653c - K3f44216, t5c980 - N7d6367)
	end
	local n78e42699c = function(W1d137d1dc41, C4292d601e8, s7ed26e7c8, c55435, ka2a921cc9af, y94bc89fac9, Peed049872df, X694716, e8bf1daa2d59, E24a90, V176fa, y77189a5)
		return W1d137d1dc41 <= X694716 and Peed049872df <= C4292d601e8 and s7ed26e7c8 <= E24a90 and e8bf1daa2d59 <= c55435 and ka2a921cc9af <= y77189a5 and V176fa <= y94bc89fac9
	end
	local function z759834a(e825d8c7c, Mfb6a7, Zc08d6, X98884)
		local Cdc7fee, s87132, w5590f, R1e0d30c12f, me41e06d, r60c17d0c8 = k3f5564(e825d8c7c, Mfb6a7)
		local s39fe02ad21, I91a0cd, y8296666941, pa0ff4ae, lbad5bd319ab, Nf3a1b24 = k3f5564(Zc08d6, X98884)
		return n78e42699c(Cdc7fee, s87132, w5590f, R1e0d30c12f, me41e06d, r60c17d0c8, s39fe02ad21, I91a0cd, y8296666941, pa0ff4ae, lbad5bd319ab, Nf3a1b24)
	end
	local function n6d68f222b5(G4ba99ebad)
		local ca1c9eb7e69, seb391d, uf164455 = Vector3.new(1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1)
		for X34ec1 = 1, #G4ba99ebad do
			local n5a6b4 = G4ba99ebad[X34ec1]
			local C50ac4da, c2891702a6a3 = n5a6b4.CFrame, n5a6b4.Size
			local J425479, ne8b720b6, aff588fc2, f7b9683c, gac65f1, lae6b40367 = k3f5564(C50ac4da, c2891702a6a3, ca1c9eb7e69, seb391d, uf164455)
			for Yddae17c4b9 = X34ec1 + 1, #G4ba99ebad do
				local ec163da8 = G4ba99ebad[Yddae17c4b9]
				local cbe525b, qb5a492d81c = ec163da8.CFrame, ec163da8.Size
				local Jc34896d697, mc09ed99b, Ye136c5b942, Jd12520f304, z9091c, ea7edceb4705 = k3f5564(cbe525b, qb5a492d81c, ca1c9eb7e69, seb391d, uf164455)
				if n78e42699c(J425479, ne8b720b6, aff588fc2, f7b9683c, gac65f1, lae6b40367, Jc34896d697, mc09ed99b, Ye136c5b942, Jd12520f304, z9091c, ea7edceb4705) then
					return true
				end
			end
		end
		return false
	end
	local p70f8b = function(nda6d9dc38e, Bfa05c, N956afa22dc, K87759d0a4, ge4eec294a8f, Hf4c9f86800e, z76b1e, X919b5330a)
		return nda6d9dc38e <= Hf4c9f86800e and ge4eec294a8f <= Bfa05c and N956afa22dc <= X919b5330a and z76b1e <= K87759d0a4
	end
	local Fdf7cfe = function(S98bd44, Ua203c0f8d, J7f97bd5, f8a153c3502, h027a2ed, O7692e3fa, n5e5b029, Q9285509b5)
		return h027a2ed <= S98bd44 and Ua203c0f8d <= O7692e3fa and n5e5b029 <= J7f97bd5 and f8a153c3502 <= Q9285509b5
	end
	local ad2e0de3 = function(e2e1468994, K00098aae13b, Rfd78c277d84, T3cdcac, v00eff31, Q99b3b15)
		return Rfd78c277d84 <= e2e1468994 and e2e1468994 <= T3cdcac and v00eff31 <= K00098aae13b and K00098aae13b <= Q99b3b15
	end
	local function jc3eb56(xd01fd6c9, f3f74c2fb978, M031f8f9f629, Zf40a11434)
		local Y6ace85be1 = u83075b(f3f74c2fb978, Zf40a11434)
		if x8080a8b(Y6ace85be1) <= 1.0E-6 then
			return false
		end
		local Ie23da = u83075b(M031f8f9f629 - xd01fd6c9, Zf40a11434)
		if Ie23da > 0 then
			return false
		end
		return true, xd01fd6c9 + f3f74c2fb978 * (Ie23da / Y6ace85be1)
	end
	local function pc1b3b(q8cacb90d97, wa048d352, O0d707261d, J4c6a3, zd703be4, z0a16d37648, Rdb5588b5e, i9997ce6ad)
		local nc799b3 = (i9997ce6ad - z0a16d37648) * (O0d707261d - q8cacb90d97) - (Rdb5588b5e - zd703be4) * (J4c6a3 - wa048d352)
		local x0b9e4b61 = (Rdb5588b5e - zd703be4) * (wa048d352 - z0a16d37648) - (i9997ce6ad - z0a16d37648) * (q8cacb90d97 - zd703be4)
		local sf2f02f4ee64 = (O0d707261d - q8cacb90d97) * (wa048d352 - z0a16d37648) - (J4c6a3 - wa048d352) * (q8cacb90d97 - zd703be4)
		if x8080a8b(x0b9e4b61) < 0.001 and x8080a8b(sf2f02f4ee64) < 0.001 and x8080a8b(nc799b3) < 0.001 then
			return true
		end
		if x8080a8b(nc799b3) < 0.001 then
			return false
		end
		local G0bb7e01b, U012e65231a = x0b9e4b61 / nc799b3, sf2f02f4ee64 / nc799b3
		if G0bb7e01b <= 0 or G0bb7e01b > 1 or U012e65231a <= 0 or U012e65231a > 1 then
			return false
		end
		return true
	end
	Ce1650f7ed.SingleAABB = mf577c
	Ce1650f7ed.SingleAABBRaw = k3f5564
	Ce1650f7ed.MultiAABB = r12fab7
	Ce1650f7ed.MultiAABBRaw = E9d5883b
	Ce1650f7ed.IntersectAABB = n78e42699c
	Ce1650f7ed.IntersectPrism = z759834a
	Ce1650f7ed.IntersectMultiPrism = n6d68f222b5
	Ce1650f7ed.IntersectRectangleRaw = p70f8b
	Ce1650f7ed.ContainRectangleRaw = Fdf7cfe
	Ce1650f7ed.IsPointInRectangleRaw = ad2e0de3
	Ce1650f7ed.IntersectRayPlane = jc3eb56
end
do
	local K89892c = math.cos
	local Y4c4c891ec95 = math.tan
	local function X4d715211f2(Efdc1424, l1c769409, V8c66d0afc, P4db629, O2aaf0, h141bb)
		local qb0fa31334 = O2aaf0 - Efdc1424
		if V8c66d0afc <= l1c769409:Dot(qb0fa31334) then
			return false
		end
		local V8c60ae9ac = qb0fa31334:Dot(l1c769409)
		local t8005dd49bd5 = V8c60ae9ac * Y4c4c891ec95(P4db629)
		local F33a21c7f06 = (qb0fa31334:Dot(qb0fa31334) - V8c60ae9ac * V8c60ae9ac) ^ 0.5
		local Bb6909e80 = F33a21c7f06 - t8005dd49bd5
		local Xe3435 = Bb6909e80 * K89892c(P4db629)
		return h141bb >= Xe3435
	end
	Ce1650f7ed.DoesFixedConeIntersectSphere = X4d715211f2
end
do
	local n034703, ka7178dc009c = math.asin, math.atan
	local y37a144e05b9, E26e98fec = math.cos, math.sin
	local function wb0cbd2104(ce2bf9, t0c6b75245a, s885ffb3917b, v1788812e99, Sf4e244, Ib7f4fa)
		if v1788812e99 == 0 or Sf4e244 == 0 or Ib7f4fa == 0 then
			return 0, 0
		end
		local Y7f007 = v1788812e99 * v1788812e99 + Ib7f4fa * Ib7f4fa
		local Vc7bac63c553 = (Ib7f4fa < 0 and ka7178dc009c(v1788812e99 / Ib7f4fa) or math.pi - ka7178dc009c(-v1788812e99 / Ib7f4fa)) + (Y7f007 > ce2bf9 * ce2bf9 and n034703(ce2bf9 / Y7f007 ^ 0.5) or n034703(Y7f007 ^ 0.5 / ce2bf9))
		local jc10db, w02562 = y37a144e05b9(Vc7bac63c553), E26e98fec(Vc7bac63c553)
		v1788812e99, Sf4e244, Ib7f4fa = v1788812e99 * jc10db - Ib7f4fa * w02562, Sf4e244, Ib7f4fa * jc10db + v1788812e99 * w02562
		local q8824176577e = Sf4e244 * Sf4e244 + Ib7f4fa * Ib7f4fa
		local l551bae5a8f5 = (Ib7f4fa < 0 and ka7178dc009c(-Sf4e244 / Ib7f4fa) or ka7178dc009c(Sf4e244 / Ib7f4fa)) - (q8824176577e > t0c6b75245a * t0c6b75245a and n034703(t0c6b75245a / q8824176577e ^ 0.5) or n034703(q8824176577e ^ 0.5 / t0c6b75245a))
		return Vc7bac63c553, l551bae5a8f5
	end
	Ce1650f7ed.OffsetLookAtTarget = wb0cbd2104
end
do
	local ted77875 = function(Zcf69ec554cc, V3aa845f007, p42325631, pcdd27929be)
		local ac65b0a532c = 0
		while true do
			ac65b0a532c = ac65b0a532c + 1
			local Vf03919bfd1c = Ray.new(Zcf69ec554cc, V3aa845f007 * p42325631)
			local j3a9a40eef8, o5e80f8, J632e23 = workspace:FindPartOnRayWithIgnoreList(Vf03919bfd1c, pcdd27929be)
			local e5259154 = (o5e80f8 - Zcf69ec554cc).Magnitude
			p42325631 = p42325631 - e5259154
			Zcf69ec554cc = o5e80f8
			if j3a9a40eef8 and j3a9a40eef8.CanCollide then
				V3aa845f007 = V3aa845f007 - 2 * V3aa845f007:Dot(J632e23) * J632e23
			end
			if p42325631 <= 0 or e5259154 < 0.001 or ac65b0a532c > 10 then
				break
			end
		end
		return Zcf69ec554cc, V3aa845f007
	end
	local Mf79ae517fb = function(Y240f356019c, Bd7a3be, Ke3f04651b1, N9aa472)
		local Xf8f85 = 0
		while true do
			Xf8f85 = Xf8f85 + 1
			local m8063151005 = Ray.new(Y240f356019c, Bd7a3be * Ke3f04651b1)
			local h4dce20d965, fcfb413, m085fa5f7c85 = workspace:FindPartOnRayWithIgnoreList(m8063151005, N9aa472)
			local E7ace99df = (fcfb413 - Y240f356019c).Magnitude
			Ke3f04651b1 = Ke3f04651b1 - E7ace99df
			Y240f356019c = fcfb413
			if h4dce20d965 then
				if h4dce20d965.CanCollide then
					return Y240f356019c, Bd7a3be, h4dce20d965
				else
					table.insert(N9aa472, h4dce20d965)
				end
			end
			if Ke3f04651b1 <= 0 or E7ace99df < 0.001 or Xf8f85 > 10 then
				break
			end
		end
		return Y240f356019c, Bd7a3be
	end
	Ce1650f7ed.SinkRay = Mf79ae517fb
	Ce1650f7ed.TraceBounceRay = ted77875
end
return Ce1650f7ed
