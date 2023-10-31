//  TODO complex polygons (ie, with holes in the center)
// TODO properly flip polygons when folding??? (solved?)
// TODO fold seperation stuff + bends around folds
// NOTE currently all polygons must be declared with the right hand rule

$folded=1;
// Useful for showing fold-edges on a 2D projection, also a non-zero amount is
// necessary for the polyhedrons to be considered valid
// $foldsep=0.1; 
// Nice way of only seperating when unfolded
$foldsep=$folded ? 0.00001 : 0.1; 

// We don't let the  user provide a fold object here because they have to
// define the edge anyways, and I wan't to make it easier for people to fold
// polygons with holes in them
function fold(plane_norm,edge,max_angle,poly) = 
	let (
		edge_vec=edge[1]-edge[0],
		edge_vec_u=edge_vec/norm(edge_vec),
		edge_perp=cross(edge_vec_u,plane_norm),
		angle=max_angle*$folded,
		fold_vec=cos(angle)*edge_perp+sin(angle)*plane_norm,
		poly2=[
			for (i=[0:len(poly)-1])
				let (p=poly[i],px=p[0],py=p[1])
					edge_vec_u*px+fold_vec*(py+$foldsep)+edge[0]
		],
		new_norm=cross(fold_vec,edge_vec_u)
	) [poly2,new_norm];

module fold_extrude(fold_obj,thick,poly,plane_norm) {
	poly=poly == undef ? fold_obj[0] : poly;
	plane_norm=plane_norm == undef ? fold_obj[1] : plane_norm;
	pointc=len(poly);
	inner_points=poly;	
	outer_points=[
		for (i=[0:pointc-1])
			poly[i]-plane_norm*thick
	];
	both=concat(inner_points,outer_points);
	polyhedron(points=both,faces=[
			[for (i=[0:pointc-1]) i],
			[for (i=[2*pointc-1:-1:pointc]) i],
			for (i=[0:pointc-1]) 
				let (next = i+1==pointc ? 0 : i+1)
				[
					i,
					i+pointc,
					next+pointc,
					next
				]
		]);
}

// This naming scheme is just a placeholder, plenty of other ways to do it
p_square=[
	[0,0],
	[1,0],
	[1,1],
	[0,1]
];

o_square=fold([0,0,1],[[2,0,0],[5,1,0]],30,p_square);
f_square=o_square[0];
n_square=o_square[1];

p_tri=[
	[0,0],
	[1,0],
	[0.5,1]
];

o_tri=fold(n_square,[f_square[2],f_square[1]],60,p_tri);
f_tri=o_tri[0];
n_tri=o_tri[1];

fold_extrude(o_square,0.2);
fold_extrude(o_tri,0.2);
