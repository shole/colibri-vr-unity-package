/// Copyright 2019-2020 MINES ParisTech (PSL University)
/// This work is licensed under the terms of the MIT license, see the LICENSE file.
/// 
/// Author: Grégoire Dupont de Dinechin, gregoire@dinechin.org



/// <summary> 
/// Contains methods related to converting information to and from ARGB color textures.
/// </summary>
#ifndef COLOR_CG_INCLUDED
#define COLOR_CG_INCLUDED

/// PRECISECOLOR

    /// </summary>
    /// Encodes a 0-1 float value with 24-bit precision as an RGB color.
    /// Useful when the encoded information has to be decoded afterwards with high precision.
    /// </summary>
    inline float4 Encode01AsPreciseColor(float value01)
    {
        return float4(EncodeFloatRGBA(clamp(value01, 0, 1.0 - 1/16581375.0)).rgb, 1);
    }

    /// <summary>
    /// Decodes an RGB color with 24-bit precision as a 0-1 float.
    /// </summary>
    inline float Decode01FromPreciseColor(float4 colorValue)
    {
        return DecodeFloatRGBA(float4(colorValue.rgb, 1));
    }

/// ENDPRECISECOLOR

/// HSV

    /// <summary>
    /// Converts from HSV to RGB color space.
    /// </summary>
    inline float3 HSVtoRGB(float3 colorHSV)
    {
        float4 tempA = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
        float3 tempB = abs(frac(colorHSV.xxx + tempA.xyz) * 6.0 - tempA.www);
        return colorHSV.z * lerp(tempA.xxx, clamp(tempB - tempA.xxx, 0.0, 1.0), colorHSV.y);
    }

    /// <summary>
    /// Computes a color from the given index and maximum index.
    /// </summary>
    inline float3 GetColorForIndex(uint index, uint maxIndex)
    {
        const uint baseColorCount = 6;
        const uint skipCount = 1;
        uint skipIndex = index * (skipCount + 1);
        uint skipIters = floor(skipIndex * 1.0 / baseColorCount);
        uint hLoopCount = floor(index * 1.0 / baseColorCount);
        float h = ((skipIndex + skipIters) % baseColorCount + 1.0 - pow(0.5, hLoopCount)) * 1.0 / baseColorCount;
        float s = 1.0;
        float v = 1.0 - 0.5 * (index * 1.0 / maxIndex);
        return HSVtoRGB(float3(h, s, v));
    }

/// ENDHSV

/// PLASMA

    /// <summary>
    /// Plasma color encoding, with 256 levels.
    /// Extracted from https://www.kennethmoreland.com/color-advice/
    /// </summary>
    static fixed3 _Plasma[256] =
    {
        fixed3(0.185001263, 0, 0.530073448),
        fixed3(0.191118904, 0, 0.53524446),
        fixed3(0.197128649, 0, 0.540149687),
        fixed3(0.203041623, 0, 0.544820727),
        fixed3(0.208872681, 0, 0.549286108),
        fixed3(0.214630723, 0, 0.553569657),
        fixed3(0.220321577, 0, 0.557688614),
        fixed3(0.225957561, 0, 0.561660996),
        fixed3(0.231550398, 0, 0.565504924),
        fixed3(0.237106416, 0, 0.569231401),
        fixed3(0.242629405, 0, 0.572850562),
        fixed3(0.248125101, 0, 0.576370295),
        fixed3(0.253595834, 0, 0.579798844),
        fixed3(0.259047386, 0, 0.583142982),
        fixed3(0.264479879, 0, 0.586406035),
        fixed3(0.269898106, 0, 0.589594879),
        fixed3(0.275304383, 0, 0.592712325),
        fixed3(0.280699007, 0, 0.595760791),
        fixed3(0.28608641, 0, 0.598744854),
        fixed3(0.291463882, 0, 0.601664998),
        fixed3(0.296835118, 0, 0.604523714),
        fixed3(0.302199178, 0, 0.607321565),
        fixed3(0.307559383, 0, 0.610060282),
        fixed3(0.312916649, 0, 0.612741561),
        fixed3(0.318269938, 0, 0.615364022),
        fixed3(0.323622576, 0, 0.617929015),
        fixed3(0.328970997, 0, 0.620434224),
        fixed3(0.334318703, 0, 0.622882935),
        fixed3(0.339663737, 0, 0.625271898),
        fixed3(0.345007808, 0, 0.627601319),
        fixed3(0.350348474, 0, 0.629871024),
        fixed3(0.355687415, 0, 0.632078594),
        fixed3(0.361025812, 0, 0.634225582),
        fixed3(0.366361534, 0, 0.63630788),
        fixed3(0.371696324, 0, 0.638326548),
        fixed3(0.377027696, 0, 0.640278553),
        fixed3(0.382357947, 0, 0.642162877),
        fixed3(0.387684382, 0, 0.643978569),
        fixed3(0.393006286, 0, 0.645723093),
        fixed3(0.398327372, 0, 0.647395877),
        fixed3(0.403642582, 0, 0.648995054),
        fixed3(0.408954316, 0, 0.650518431),
        fixed3(0.414260016, 0, 0.65196423),
        fixed3(0.419562395, 0, 0.653331172),
        fixed3(0.424856362, 0, 0.654616564),
        fixed3(0.430144178, 0, 0.655818742),
        fixed3(0.435426882, 0, 0.656937996),
        fixed3(0.44069994, 0, 0.657969728),
        fixed3(0.445966446, 0, 0.658913466),
        fixed3(0.451222287, 0, 0.65976672),
        fixed3(0.456469763, 0, 0.660528912),
        fixed3(0.461705665, 0, 0.66119766),
        fixed3(0.466931002, 0, 0.661772147),
        fixed3(0.472144757, 0, 0.662249488),
        fixed3(0.477345841, 0, 0.662629425),
        fixed3(0.482534616, 0, 0.662909149),
        fixed3(0.487709033, 0, 0.66308751),
        fixed3(0.492869054, 0, 0.663164587),
        fixed3(0.498013387, 0, 0.66313835),
        fixed3(0.50314126, 0, 0.663006803),
        fixed3(0.508253183, 0, 0.662770891),
        fixed3(0.513346212, 0, 0.662428711),
        fixed3(0.518422026, 0, 0.661980097),
        fixed3(0.523477856, 0, 0.661424268),
        fixed3(0.528514349, 0, 0.66075993),
        fixed3(0.533530696, 0, 0.659987435),
        fixed3(0.538524479, 0, 0.659105598),
        fixed3(0.543498095, 0, 0.65811618),
        fixed3(0.548448103, 0, 0.657019663),
        fixed3(0.553375088, 0, 0.655814493),
        fixed3(0.558276653, 0, 0.654502281),
        fixed3(0.563155406, 0, 0.653083357),
        fixed3(0.56800819, 0, 0.651560455),
        fixed3(0.572833398, 0, 0.649932201),
        fixed3(0.577634274, 0, 0.64820017),
        fixed3(0.582407674, 0, 0.646367224),
        fixed3(0.587153398, 0, 0.644433441),
        fixed3(0.591870121, 0, 0.642401805),
        fixed3(0.596560437, 0, 0.640273283),
        fixed3(0.601220184, 0, 0.638049964),
        fixed3(0.605851218, 0, 0.63573471),
        fixed3(0.610452126, 0.0000387, 0.63332972),
        fixed3(0.615022522, 0.007471929, 0.630837399),
        fixed3(0.619562862, 0.015271185, 0.628260096),
        fixed3(0.62407198, 0.023435206, 0.625602124),
        fixed3(0.628551358, 0.031974232, 0.62286413),
        fixed3(0.632998922, 0.040877125, 0.620050518),
        fixed3(0.637416296, 0.049418977, 0.617163851),
        fixed3(0.641800481, 0.057376592, 0.614208615),
        fixed3(0.64615368, 0.064892097, 0.611187074),
        fixed3(0.650476136, 0.072056647, 0.608100445),
        fixed3(0.654765117, 0.078934856, 0.6049563),
        fixed3(0.659024526, 0.085578964, 0.601753039),
        fixed3(0.663251655, 0.092021751, 0.598498304),
        fixed3(0.667447729, 0.098296435, 0.595192427),
        fixed3(0.671610803, 0.104420776, 0.591841107),
        fixed3(0.675742966, 0.110415739, 0.588446501),
        fixed3(0.679845406, 0.116299823, 0.585011736),
        fixed3(0.683915952, 0.122079724, 0.581539558),
        fixed3(0.687956895, 0.127770614, 0.578033201),
        fixed3(0.691965282, 0.133377892, 0.574497452),
        fixed3(0.695945004, 0.138912655, 0.570932507),
        fixed3(0.699894147, 0.144379022, 0.567344186),
        fixed3(0.703813686, 0.149783463, 0.563733577),
        fixed3(0.707703608, 0.155132779, 0.560101746),
        fixed3(0.711564868, 0.160428861, 0.55645455),
        fixed3(0.715397487, 0.165677539, 0.552792121),
        fixed3(0.719200311, 0.170881106, 0.549117317),
        fixed3(0.722976323, 0.176044313, 0.545432268),
        fixed3(0.726724487, 0.181167546, 0.541740848),
        fixed3(0.730443717, 0.186254928, 0.538043103),
        fixed3(0.734137752, 0.19131016, 0.534340088),
        fixed3(0.73780375, 0.196332838, 0.530636682),
        fixed3(0.741445424, 0.201327518, 0.526932992),
        fixed3(0.745058735, 0.206293657, 0.523229886),
        fixed3(0.748648335, 0.211235423, 0.519527476),
        fixed3(0.752210475, 0.216151778, 0.515830631),
        fixed3(0.755748681, 0.221046575, 0.5121374),
        fixed3(0.759262902, 0.2259212, 0.50844983),
        fixed3(0.76275206, 0.23077447, 0.50476879),
        fixed3(0.766216825, 0.235612106, 0.501093375),
        fixed3(0.769658293, 0.240430476, 0.497427465),
        fixed3(0.773077108, 0.245235118, 0.493770163),
        fixed3(0.77647139, 0.250022378, 0.490123324),
        fixed3(0.77984282, 0.254797464, 0.486486989),
        fixed3(0.783192064, 0.259560294, 0.482859221),
        fixed3(0.786518209, 0.264310222, 0.47924185),
        fixed3(0.789822893, 0.269051327, 0.475635009),
        fixed3(0.793105143, 0.273781885, 0.472038517),
        fixed3(0.796365626, 0.278504835, 0.468452519),
        fixed3(0.799603457, 0.283218346, 0.46487782),
        fixed3(0.802820131, 0.287926379, 0.461312572),
        fixed3(0.806015919, 0.29262694, 0.457760576),
        fixed3(0.809188451, 0.297321787, 0.454217885),
        fixed3(0.812341397, 0.302013496, 0.450685578),
        fixed3(0.815471941, 0.306701168, 0.44716342),
        fixed3(0.818582553, 0.311386513, 0.443649595),
        fixed3(0.821670544, 0.316068529, 0.440145855),
        fixed3(0.824737377, 0.320749929, 0.436650386),
        fixed3(0.827782268, 0.325430709, 0.433163923),
        fixed3(0.830806026, 0.33011024, 0.429687565),
        fixed3(0.833809139, 0.334792115, 0.426217371),
        fixed3(0.836789978, 0.339474198, 0.422755077),
        fixed3(0.839748971, 0.344160147, 0.419298869),
        fixed3(0.842685448, 0.34884781, 0.415849471),
        fixed3(0.845600817, 0.353539789, 0.412405088),
        fixed3(0.848493484, 0.358234915, 0.408967423),
        fixed3(0.851363127, 0.362934578, 0.405535554),
        fixed3(0.854210286, 0.367641217, 0.402106545),
        fixed3(0.857033404, 0.372353622, 0.398682091),
        fixed3(0.85983484, 0.377073324, 0.395260409),
        fixed3(0.862611072, 0.381799115, 0.391842171),
        fixed3(0.865364358, 0.386534583, 0.388424573),
        fixed3(0.868092315, 0.391277412, 0.385011298),
        fixed3(0.870795437, 0.396030011, 0.381598402),
        fixed3(0.873474372, 0.400793693, 0.378185952),
        fixed3(0.876126664, 0.405566165, 0.374774617),
        fixed3(0.878753574, 0.410350986, 0.371362578),
        fixed3(0.881352677, 0.415145839, 0.367950494),
        fixed3(0.883926163, 0.419955302, 0.364536532),
        fixed3(0.886470716, 0.424775999, 0.361122353),
        fixed3(0.888987875, 0.429609255, 0.357706012),
        fixed3(0.891477176, 0.434458428, 0.354286512),
        fixed3(0.893936268, 0.439321144, 0.3508645),
        fixed3(0.896366405, 0.44419993, 0.347440141),
        fixed3(0.898766189, 0.449092409, 0.34401207),
        fixed3(0.901134846, 0.454002145, 0.340580414),
        fixed3(0.903471046, 0.458926722, 0.337144801),
        fixed3(0.905776262, 0.463869484, 0.33370422),
        fixed3(0.90804814, 0.468829719, 0.330258679),
        fixed3(0.910286353, 0.473806999, 0.326808781),
        fixed3(0.912490997, 0.478803918, 0.323352618),
        fixed3(0.914660855, 0.483818996, 0.319891793),
        fixed3(0.916796066, 0.488852804, 0.316425427),
        fixed3(0.918893314, 0.493906919, 0.312952017),
        fixed3(0.920954228, 0.498979593, 0.309473602),
        fixed3(0.922978164, 0.504074218, 0.305987047),
        fixed3(0.924963059, 0.509188239, 0.302494952),
        fixed3(0.926909885, 0.514324293, 0.298996343),
        fixed3(0.928815527, 0.519480841, 0.295490746),
        fixed3(0.930682937, 0.524660519, 0.2919792),
        fixed3(0.932507023, 0.529860774, 0.288458179),
        fixed3(0.934289727, 0.535084263, 0.2849297),
        fixed3(0.936029054, 0.540329367, 0.281395265),
        fixed3(0.937724397, 0.545597458, 0.277853707),
        fixed3(0.939377093, 0.550889912, 0.274303837),
        fixed3(0.940984266, 0.556204065, 0.270748164),
        fixed3(0.94254567, 0.561542659, 0.267184547),
        fixed3(0.944059431, 0.566904011, 0.263615446),
        fixed3(0.945527134, 0.572291915, 0.260035629),
        fixed3(0.946945116, 0.577701611, 0.256449604),
        fixed3(0.948313619, 0.583136522, 0.252857038),
        fixed3(0.949632951, 0.588597046, 0.249257633),
        fixed3(0.950901339, 0.594080436, 0.245651766),
        fixed3(0.952119368, 0.59959051, 0.242040161),
        fixed3(0.953283333, 0.605124496, 0.238423115),
        fixed3(0.954395789, 0.610684215, 0.234800378),
        fixed3(0.955453089, 0.616267867, 0.231174198),
        fixed3(0.956456427, 0.621876888, 0.227544138),
        fixed3(0.95740398, 0.627512736, 0.223909657),
        fixed3(0.958293078, 0.633174597, 0.220270852),
        fixed3(0.959125245, 0.638862324, 0.216629436),
        fixed3(0.959897905, 0.644575061, 0.212987497),
        fixed3(0.960612472, 0.650313704, 0.209346689),
        fixed3(0.961266356, 0.656078387, 0.205706905),
        fixed3(0.961858762, 0.661868564, 0.202070659),
        fixed3(0.962388756, 0.667685725, 0.198439292),
        fixed3(0.962855911, 0.67352794, 0.194814813),
        fixed3(0.963259441, 0.679397183, 0.191198694),
        fixed3(0.963597017, 0.68529149, 0.187594941),
        fixed3(0.963868696, 0.691213883, 0.18400289),
        fixed3(0.964073331, 0.697160331, 0.180429776),
        fixed3(0.964208898, 0.703132363, 0.176877971),
        fixed3(0.964276205, 0.709133538, 0.173347625),
        fixed3(0.964272229, 0.715158789, 0.169847148),
        fixed3(0.964197873, 0.721211193, 0.166379216),
        fixed3(0.964050024, 0.727288688, 0.16295001),
        fixed3(0.9638285, 0.733394383, 0.159563469),
        fixed3(0.963533368, 0.739524154, 0.156228266),
        fixed3(0.963161452, 0.745679575, 0.152949465),
        fixed3(0.962712539, 0.751862222, 0.149734558),
        fixed3(0.962186693, 0.758069961, 0.146593724),
        fixed3(0.961581626, 0.764303944, 0.143534308),
        fixed3(0.960894345, 0.770564039, 0.140564498),
        fixed3(0.960123446, 0.776851428, 0.137691248),
        fixed3(0.959270238, 0.783162896, 0.134930422),
        fixed3(0.958333449, 0.789499041, 0.132294012),
        fixed3(0.957312624, 0.795862498, 0.129792104),
        fixed3(0.95620623, 0.802248015, 0.127439804),
        fixed3(0.955013558, 0.80865885, 0.125247755),
        fixed3(0.953729761, 0.815095797, 0.123223003),
        fixed3(0.952353172, 0.821559114, 0.121378679),
        fixed3(0.950887428, 0.828044486, 0.119731491),
        fixed3(0.949333713, 0.834553208, 0.118292153),
        fixed3(0.947687451, 0.841083996, 0.117066462),
        fixed3(0.945940679, 0.847642583, 0.116054023),
        fixed3(0.9441033, 0.854222547, 0.115271041),
        fixed3(0.942178006, 0.860820547, 0.114718513),
        fixed3(0.940142659, 0.867449109, 0.114377318),
        fixed3(0.938020989, 0.874093706, 0.114261652),
        fixed3(0.935800082, 0.880761832, 0.114347473),
        fixed3(0.933481672, 0.887450109, 0.11461834),
        fixed3(0.931072073, 0.894156229, 0.115054175),
        fixed3(0.928560619, 0.900886024, 0.115611416),
        fixed3(0.925959447, 0.907631054, 0.11625593),
        fixed3(0.923270536, 0.914393832, 0.116928619),
        fixed3(0.920481689, 0.921176091, 0.11754607),
        fixed3(0.917616315, 0.9279733, 0.118026955),
        fixed3(0.914676591, 0.934779144, 0.118241752),
        fixed3(0.911670017, 0.941596587, 0.118020596),
        fixed3(0.908606826, 0.948423631, 0.117124702),
        fixed3(0.905512279, 0.955251124, 0.115218294),
        fixed3(0.90242203, 0.962072973, 0.111794796),
        fixed3(0.899408009, 0.96886619, 0.106073432),
        fixed3(0.89655977, 0.975611979, 0.096681484),
        fixed3(0.89405831, 0.982253579, 0.081068766)
    };

    /// <summary>
    /// Encodes a 0-1 float value with 8-bit precision using the Plasma colormap.
    /// Useful for visualization, but not very precise.
    /// </summary>
    inline fixed4 Encode01AsPlasma(float value01)
    {
        uint index = clamp(round(255 * value01), 0, 255);
        return fixed4(_Plasma[index], 1);
    }
    
/// ENDPLASMA

#endif // COLOR_CG_INCLUDED
