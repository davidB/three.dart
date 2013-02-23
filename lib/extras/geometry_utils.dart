library GeometryUtils;

import "package:three/three.dart";

// TODO(nelsonsilva) - Add remaining functions
clone( Geometry geometry ) {

    var cloneGeo = new Geometry();

    var i, il;

    var vertices = geometry.vertices,
      faces = geometry.faces,
      uvs = geometry.faceVertexUvs[ 0 ];

    // materials

    if ( geometry.materials != null) {

      cloneGeo.materials = new List.from(geometry.materials);

    }

    // vertices
    cloneGeo.vertices = vertices.mappedBy((vertex) => vertex.clone()).toList();

    // faces
    cloneGeo.faces = faces.mappedBy((face) => face.clone()).toList();

    // uvs
    il = uvs.length;
    for ( i = 0; i < il; i ++ ) {

      var uv = uvs[ i ], uvCopy = [];

      var jl = uv.length;
      for ( var j = 0; j < jl; j ++ ) {

        uvCopy.add( new UV( uv[ j ].u, uv[ j ].v ) );

      }

      cloneGeo.faceVertexUvs[ 0 ].add( uvCopy );

    }

    return cloneGeo;

}

void mergeMesh(Geometry geometry1, Mesh object2) {
  if (object2.matrixAutoUpdate) object2.updateMatrix();
  var matrix = object2.matrix;
  var normalMatrix = new Matrix3();
  normalMatrix.getInverse( matrix );
  normalMatrix.transpose();
  merge (geometry1, object2.geometry, matrix, normalMatrix);
}

void merge(Geometry geometry1, Geometry geometry2, [Matrix4 matrix, Matrix3 normalMatrix]) {

  var vertexOffset = geometry1.vertices.length;
  var uvPosition = geometry1.faceVertexUvs[ 0 ].length;
  var vertices1 = geometry1.vertices;
  var vertices2 = geometry2.vertices;
  var faces1 = geometry1.faces;
  var faces2 = geometry2.faces;
  var uvs1 = geometry1.faceVertexUvs[ 0 ];
  var uvs2 = geometry2.faceVertexUvs[ 0 ];

  // vertices
  for ( var i = 0, il = vertices2.length; i < il; i ++ ) {
    var vertex = vertices2[ i ];
    var vertexCopy = vertex.clone();
    if ( matrix != null) vertexCopy.applyMatrix4( matrix );
    vertices1.add( vertexCopy );
  }

  // faces
  for (var i = 0, il = faces2.length; i < il; i ++ ) {
    var face = faces2[ i ], faceCopy, normal, color,
        faceVertexNormals = face.vertexNormals,
        faceVertexColors = face.vertexColors;

    if ( face is Face3 ) {
      faceCopy = new Face3( face.a + vertexOffset, face.b + vertexOffset, face.c + vertexOffset );
    } else if ( face is Face4 ) {
      faceCopy = new Face4( face.a + vertexOffset, face.b + vertexOffset, face.c + vertexOffset, face.d + vertexOffset );
    }

    faceCopy.normal.copy( face.normal );
    if ( normalMatrix != null ) {
      faceCopy.normal.applyMatrix3( normalMatrix ).normalize();
    }

    for ( var j = 0, jl = faceVertexNormals.length; j < jl; j ++ ) {
      normal = faceVertexNormals[ j ].clone();
      if ( normalMatrix != null ) {
        normal.applyMatrix3( normalMatrix ).normalize();
      }
      faceCopy.vertexNormals.add( normal );
    }

    faceCopy.color.copy( face.color );
    for ( var j = 0, jl = faceVertexColors.length; j < jl; j ++ ) {
      color = faceVertexColors[ j ];
      faceCopy.vertexColors.add( color.clone() );
    }

    faceCopy.materialIndex = face.materialIndex;
    faceCopy.centroid.copy( face.centroid );

    if ( matrix != null) {
      faceCopy.centroid.applyMatrix4( matrix );
    }

    faces1.add( faceCopy );
  }

  // uvs

  for (var i = 0, il = uvs2.length; i < il; i ++ ) {
    var uv = uvs2[ i ], uvCopy = [];
    for ( var j = 0, jl = uv.length; j < jl; j ++ ) {
      uvCopy.add( new Vector2( uv[ j ].u, uv[ j ].v ) );
    }
    uvs1.add( uvCopy );
  }

}