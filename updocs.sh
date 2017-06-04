#!/bin/sh

GROUP=io/playn
VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: $0 M.N"
    echo "Where M.N is the version of the just performed release."
    exit 255
fi

unpack() {
    ARTIFACT=playn-$1
    COREDIR=$HOME/.m2/repository/$GROUP/$ARTIFACT/$VERSION
    if [ ! -d $COREDIR ]; then
        echo "Can't find: $COREDIR"
        echo "Is $VERSION the correct version?"
        exit 255
    fi

    echo "Unpacking $ARTIFACT-$VERSION-javadoc.jar..."
    pushd docs/api/$1
    jar xf $COREDIR/$ARTIFACT-$VERSION-javadoc.jar
    rm -rf META-INF
    popd
}

unpack core
unpack scene

echo "Adding and committing updated docs..."
git add docs/api
git commit -m "Updated docs for $VERSION release." .
git push

echo "Tagging docs..."
git tag -a v$VERSION -m "Tagged docs for $VERSION release."
git push origin v$VERSION

echo "Thank you, please drive through."
