
#!/bin/bash

#declare -a users=("b")

#declare -a projects=("")

declare -a environments=("prod")
declare -a roles=("itops")

for user in "${users[@]}"
do
    echo "user: $user"
    for ev in "${environments[@]}"
    do
        for ns in "${projects[@]}"
        do
            echo "project: $ns-$ev"
            PROJECT_ID=$ns-$ev

            if [[ ! -z `gcloud projects describe ${PROJECT_ID} --verbosity=none` ]]; then
                gcloud config set project ${PROJECT_ID}

                for ro in "${roles[@]}"
                do
                    ROLE_NAME="role$ro"
                    FULL_ROLE_NAME="projects/${PROJECT_ID}/roles/$ROLE_NAME"
                    ROLE_FILE=role-$ro.yaml

                    echo "role: $ROLE_NAME"

                    # create/update developer role
                    if [[ -z `gcloud iam roles describe $ROLE_NAME --project=${PROJECT_ID} --verbosity=none` ]]; then
                        gcloud iam roles create $ROLE_NAME --quiet --project=${PROJECT_ID} --file=$ROLE_FILE
                    else
                        gcloud iam roles update $ROLE_NAME --quiet --project=${PROJECT_ID} --file=$ROLE_FILE
                    fi

                    gcloud projects add-iam-policy-binding $PROJECT_ID \
                        --member user:$user \
                        --role=$FULL_ROLE_NAME \
                        --condition=None --verbosity=none --quiet
                done
            fi
        done
    done
done