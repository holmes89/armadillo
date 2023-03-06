package login

import (
	"context"
	"errors"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	cognito "github.com/aws/aws-sdk-go/service/cognitoidentityprovider"
	"github.com/holmes89/armadillo/internal"
	"github.com/rs/zerolog/log"
)

type service struct {
	svc      *cognito.CognitoIdentityProvider
	clientID *string
	poolID   *string
}

func NewService() internal.LoginService {
	clientID := os.Getenv("COGNITO_CLIENT_ID")
	if clientID == "" {
		panic("COGNITO_CLIENT_ID required")
	}
	poolID := os.Getenv("COGNITO_POOL_ID")
	if clientID == "" {
		panic("COGNITO_POOL_ID required")
	}
	session := session.Must(session.NewSession())
	return &service{
		svc:      cognito.New(session),
		clientID: &clientID,
		poolID:   &poolID,
	}
	// return &service{}
}

func (s *service) Authenticate(ctx context.Context, si internal.Login) (internal.Authentication, error) {
	authInput := &cognito.InitiateAuthInput{
		ClientId: s.clientID,
	}
	auth := internal.Authentication{}
	if si.RefreshToken != nil {
		log.Info().Msg("authentication using refresh token...")
		authInput.AuthFlow = aws.String(cognito.AuthFlowTypeRefreshToken)
		authInput.AuthParameters = map[string]*string{
			"REFRESH_TOKEN": si.RefreshToken,
		}
	} else if si.Session != nil {
		log.Info().Msg("authentication using session token...")
		resp, err := s.svc.RespondToAuthChallenge(&cognito.RespondToAuthChallengeInput{

			ChallengeName: aws.String(cognito.ChallengeNameTypeNewPasswordRequired),
			ChallengeResponses: map[string]*string{
				"USERNAME":     &si.Username,
				"NEW_PASSWORD": &si.Password,
			},
			ClientId: s.clientID,
			Session:  si.Session,
		})
		if err != nil {
			log.Error().Err(err).Msg("unable to update user's password")
			return auth, errors.New("unable to authenticate user")
		}
		if resp.AuthenticationResult.AccessToken != nil {
			auth.Token = *resp.AuthenticationResult.AccessToken
		}
		if resp.AuthenticationResult.RefreshToken != nil {
			auth.RefreshToken = *resp.AuthenticationResult.RefreshToken
		}
		return auth, nil

	} else {
		log.Info().Msg("authentication using username and password...")
		authInput.AuthFlow = aws.String(cognito.AuthFlowTypeUserPasswordAuth)
		authInput.AuthParameters = map[string]*string{
			"USERNAME": &si.Username,
			"PASSWORD": &si.Password,
		}
	}

	resp, err := s.svc.InitiateAuth(authInput)
	if err != nil {
		log.Error().Err(err).Msg("unable to authenticate user")
		return auth, errors.New("unable to authenticate user")
	}
	if resp.Session != nil {
		auth.Session = resp.Session
		return auth, nil
	}
	if resp == nil || resp.AuthenticationResult == nil {
		log.Error().Err(err).Interface("msg", resp).Msg("no results")
		return auth, errors.New("unable to authenticate user")
	}

	if resp.AuthenticationResult.AccessToken != nil {
		auth.Token = *resp.AuthenticationResult.AccessToken
	}
	if resp.AuthenticationResult.RefreshToken != nil {
		auth.RefreshToken = *resp.AuthenticationResult.RefreshToken
	}

	return auth, nil
}
